require 'json'
require 'stringio'
class JsonStreamer
  include Enumerable

  attr_reader :json_sequence
  def initialize(model_class,ids,json_sequence = nil, per_page = 1000, filter_mappings = {}, &block)
    @ids = ids
    @model_class = model_class
    @json_sequence = json_sequence || self.class.json_sequence(@model_class)
    @per_page = per_page
    @filter_mappings = filter_mappings
    @block = block
  end

  def self.json_sequence(model_class)
    model_class.properties.collect {|p| p.name} - [:id]
  end

  def to_json(array)
    array.to_json
  end

  def each
    yield "["
    elements_count = @ids.size
    page_counter = 0
    while (page_counter * @per_page <= elements_count)  do
      elements = @model_class.all(:id=>@ids[page_counter*@per_page,@per_page])
      elements.each do |element|
        element = @block.call(element) unless @block.nil?
        json = element.to_json
        yield StringIO.new(json).read
        yield "," unless element == elements.last
      end
      page_counter = page_counter + 1
    end
    yield "]"
  end
end
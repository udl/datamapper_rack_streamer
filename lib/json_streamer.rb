require 'json'
require 'stringio'
class JsonStreamer
  include Enumerable

  attr_reader :json_sequence
  def initialize(model_class,ids, per_page = 1000, &block)
    @ids = ids
    @model_class = model_class
    @per_page = per_page
    @block = block
  end

  def each
    yield "["
    elements_count = @ids.size
    page_counter = 0
    while (page_counter * @per_page <= elements_count)  do
      elements = @model_class.all(:id=>@ids[page_counter*@per_page,@per_page])
      elements.each do |element|
        element = @block.call(element) unless @block.nil?
        yield element.to_json
        yield "," unless element == elements.last
      end
      page_counter = page_counter + 1
    end
    yield "]"
  end
end
require 'iconv'
require 'stringio'
require 'utf_16_bom'

class CsvStreamer
  include Enumerable
  UTF_16_LE_ICONV = Iconv.new('UTF-16LE', 'UTF-8')
  COLUMN_SEPARATOR = "\t"
  ROW_SEPARATOR = "\n"
  attr_reader :csv_sequence
  def initialize(model_class,ids,csv_sequence = nil, per_page = 1000, filter_mappings = {}, &block)
    @ids = ids
    @model_class = model_class
    @csv_sequence = csv_sequence || self.class.csv_sequence(@model_class)
    @per_page = per_page
    @filter_mappings = filter_mappings
    @block = block
  end
  
  def self.csv_sequence(model_class)
    model_class.properties.collect {|p| p.name} - [:id]
  end

  def to_csv(array)
    UTF_16_LE_ICONV.iconv(array.join(COLUMN_SEPARATOR) + ROW_SEPARATOR)
  end

  def each
    elements_count = @ids.size
    page_counter = 0
    yield utf16le_bom
    yield to_csv(@csv_sequence)
    while (page_counter * @per_page <= elements_count)  do
      elements = @model_class.all(:id=>@ids[page_counter*@per_page,@per_page])
      elements.each do |element|
        element = @block.call(element) unless @block.nil?
        csv = to_csv(@csv_sequence.collect do |field|
            fieldval = element.send(field)
            if @filter_mappings.has_key?(field)
              filterblock = eval "Proc.new {#{@filter_mappings[field]}}"
              fieldval = filterblock.call(fieldval)
            end
            fieldval
          end)
        yield StringIO.new(csv).read
      end
      page_counter = page_counter + 1
    end
  end
end
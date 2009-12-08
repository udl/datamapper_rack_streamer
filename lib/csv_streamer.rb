require 'iconv'
require 'stringio'

class CsvStreamer
  include Enumerable
  BYTE_ARRAY_UTF_BOM = [0xff, 0xfe].collect{|byte| byte.chr}.join
  UTF_16_LE_ICONV = Iconv.new('UTF-16LE', 'UTF-8')
  COLUMN_SEPARATOR = "\t"
  ROW_SEPARATOR = "\n"
  attr_reader :csv_sequence
  def initialize(model_class,ids,csv_sequence = nil, &block)
    @ids = ids
    @model_class = model_class
    @csv_sequence = csv_sequence || self.class.csv_sequence(@model_class)
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
    per_page = 1000
    page_counter = 0
    yield BYTE_ARRAY_UTF_BOM
    yield to_csv(@csv_sequence)
    while (page_counter * per_page <= elements_count)  do
      elements = @model_class.all(:id=>@ids[page_counter*per_page,per_page])
      elements.each do |element|
        element = @block.call(element) unless @block.nil?
        csv = to_csv(@csv_sequence.collect do |field|
            element.send(field)
          end)
        yield StringIO.new(csv).read
      end
      page_counter = page_counter + 1
    end
  end
end
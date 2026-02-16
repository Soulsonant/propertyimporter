require "csv"

class CsvParser
  REQUIRED_HEADERS = %w[building_name street_address city state zip_code].freeze

  def initialize(file:)
    @content = File.read(file.tempfile.path, encoding: "utf-8")
  end

  def valid_header?
    (REQUIRED_HEADERS - parsed_headers).empty?
  end

  def header_error
    missing = REQUIRED_HEADERS - parsed_headers
    "Missing required columns: #{missing.join(", ")}"
  end

  def rows
    CSV.parse(@content, headers: true, header_converters: :symbol).map.with_index do |row, idx|
      {
        "row_index"      => idx,
        "building_name"  => row[:building_name].to_s.strip,
        "street_address" => row[:street_address].to_s.strip,
        "unit"           => row[:unit].to_s.strip,
        "city"           => row[:city].to_s.strip,
        "state"          => row[:state].to_s.strip,
        "zip_code"       => row[:zip_code].to_s.strip,
        "csv_errors"     => []
      }
    end
  end

  private

  def parsed_headers
    @parsed_headers ||= CSV.parse_line(@content)
                           .map { |h| h.to_s.strip.downcase.gsub(/\s+/, "_") }
  end
end
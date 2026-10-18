require 'erb'
require 'json'
require 'net/http'
require 'uri'

# Fetches the hourly wave forecast of a Puertos del Estado (Portus) buoy and
# renders it as a static HTML table.
module PortusForecast
  API_BASE = 'https://poem.puertos.es/portus/ForecastData'.freeze
  FIELDS = %w[Datetime Hm0 Tp Tm02 MeanDir180].freeze
  TEMPLATE_PATH = File.expand_path('../templates/index.html.erb', __dir__)

  class Error < StandardError; end

  module Compass
    POINTS = %w[N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW].freeze
    SECTOR_SIZE = 360.0 / POINTS.size

    # @param degrees [Numeric] direction in degrees (0 = N, clockwise)
    # @return [String] 16-point compass label, e.g. "WSW"
    def self.from_degrees(degrees)
      POINTS[(degrees / SECTOR_SIZE).round % POINTS.size]
    end
  end

  Row = Struct.new(:time, :wave_height, :peak_period, :mean_period, :direction_degrees,
                   keyword_init: true) do
    # @return [String] propagation direction as a compass label
    def direction
      Compass.from_degrees(direction_degrees)
    end
  end

  class << self
    # @param code [String] Portus point code (e.g. "712018020")
    # @param scheme [String] forecast model scheme (e.g. "Siwana")
    # @return [Array<Row>] hourly forecast rows, oldest first
    def fetch(code:, scheme:)
      uri = URI("#{API_BASE}/#{scheme}/forecast")
      uri.query = URI.encode_www_form(code: code, fields: FIELDS.join(','))
      parse(get(uri))
    end

    # @param body [String] JSON returned by the forecast endpoint
    # @return [Array<Row>]
    def parse(body)
      data = JSON.parse(body)
      raise Error, 'Unexpected forecast payload' unless data.is_a?(Array) && data.any?

      data.map { |entry| build_row(entry) }
    rescue JSON::ParserError => e
      raise Error, "Invalid forecast JSON: #{e.message}"
    end

    # @param rows [Array<Row>]
    # @param station_name [String]
    # @param generated_at [Time]
    # @return [String] full HTML document
    def render(rows:, station_name:, generated_at:)
      ERB.new(File.read(TEMPLATE_PATH), trim_mode: '-').result(binding)
    end

    private

    def get(uri)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                                                     open_timeout: 15, read_timeout: 30) do |http|
        http.get(uri.request_uri)
      end
      raise Error, "Portus API returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    def build_row(entry)
      unless entry.is_a?(Array) && entry.size == FIELDS.size
        raise Error, "Unexpected forecast entry: #{entry.inspect}"
      end

      epoch, wave_height, peak_period, mean_period, direction = entry
      Row.new(time: Time.at(epoch), wave_height: wave_height, peak_period: peak_period,
              mean_period: mean_period, direction_degrees: direction)
    end

    def h(text)
      ERB::Util.html_escape(text)
    end
  end
end

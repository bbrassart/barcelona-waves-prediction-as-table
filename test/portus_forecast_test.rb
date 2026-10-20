ENV['TZ'] = 'Europe/Madrid'

require 'minitest/autorun'
require_relative '../lib/portus_forecast'

class CompassTest < Minitest::Test
  def test_cardinal_points
    assert_equal 'N', PortusForecast::Compass.from_degrees(0)
    assert_equal 'E', PortusForecast::Compass.from_degrees(90)
    assert_equal 'S', PortusForecast::Compass.from_degrees(180)
    assert_equal 'W', PortusForecast::Compass.from_degrees(270)
  end

  def test_sector_boundaries
    assert_equal 'WSW', PortusForecast::Compass.from_degrees(258)
    assert_equal 'W', PortusForecast::Compass.from_degrees(261)
    assert_equal 'W', PortusForecast::Compass.from_degrees(281)
    assert_equal 'WNW', PortusForecast::Compass.from_degrees(283)
    assert_equal 'NW', PortusForecast::Compass.from_degrees(304)
  end

  def test_wraps_around_north
    assert_equal 'N', PortusForecast::Compass.from_degrees(355)
    assert_equal 'N', PortusForecast::Compass.from_degrees(360)
  end
end

class ParseTest < Minitest::Test
  BODY = '[[1792285200.0,0.66,5.1,4.1,264.0],[1792288800.0,0.89,4.7,3.4,261.0]]'.freeze

  def test_parses_rows
    rows = PortusForecast.parse(BODY)

    assert_equal 2, rows.size
    assert_equal '03h00 18-10-2026', rows.first.time.strftime('%Hh%M %d-%m-%Y')
    assert_in_delta 0.66, rows.first.wave_height
    assert_equal 'W', rows.first.direction
  end

  def test_rejects_invalid_json
    assert_raises(PortusForecast::Error) { PortusForecast.parse('Internal Server Error') }
  end

  def test_rejects_empty_payload
    assert_raises(PortusForecast::Error) { PortusForecast.parse('[]') }
  end

  def test_rejects_malformed_entry
    assert_raises(PortusForecast::Error) { PortusForecast.parse('[[1792285200.0,0.66]]') }
  end
end

class RenderTest < Minitest::Test
  def test_renders_table_rows
    rows = PortusForecast.parse(ParseTest::BODY)
    html = PortusForecast.render(rows: rows, station_name: 'Boya <Test>',
                                 generated_at: Time.at(1_792_290_000))

    assert_includes html, '04h00 18-10-2026'
    assert_includes html, '<td>0.89</td>'
    assert_includes html, '<td title="261°">W (261°)</td>'
    assert_includes html, 'Boya &lt;Test&gt;'
    assert_equal 2, html.scan('<tr data-epoch=').size
  end
end

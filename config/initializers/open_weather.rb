class OpenWeatherClient
  include HTTParty
  base_uri 'https://api.openweathermap.org/data/3.0/'

  def initialize(api_key = ENV['OPENWEATHERMAP_API_KEY'])
    @api_key = api_key
  end

  def current_weather(lat:, lon:, units: 'metric')
    query = { lat: lat, lon: lon, units: units, exclude: 'minutely,hourly,daily,alerts', appid: @api_key }
    self.class.get('/onecall', query: query)
  end

  def forecast(lat:, lon:, units: 'metric')
    query = { lat: lat, lon: lon, units: units, appid: @api_key }
    self.class.get('/onecall', query: query)
  end
end

# Make the client accessible globally
OPEN_WEATHER_CLIENT = OpenWeatherClient.new
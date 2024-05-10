class OpenWeatherClient
  include HTTParty
  base_uri 'https://api.openweathermap.org/data/3.0/'

  def initialize(api_key = ENV['OPENWEATHERMAP_API_KEY'])
    @api_key = api_key
  end

end

# Make the client accessible globally
OPEN_WEATHER_CLIENT = OpenWeatherClient.new
module Weather
  # WeatherProviderOpenWeather implements BaseWeatherProvider providing for OpenWeather.
  #
  # It provides methods to retrieve weather conditions for a specific location.
  # Default is current, or pass :minutely, :hourly, :daily to get forecast data.
  #
  #
  # Usage:
  #   provider = WeatherProvider.new(latitude, longitude)
  #   current_weather = provider.current_weather()
  #   forecast = provider.forecast(latitude: 37.7749, longitude: -122.4194, units: 'imperial')
  #
  # Dependencies:
  #   - SemanticLogger: for logging
  #   - HTTParty: for making HTTP requests to the OpenWeather API
  #   - OPEN_WEATHER_CLIENT: a configured HTTParty client for the OpenWeather API
  class WeatherProviderOpenWeather
    include Weather::BaseWeatherProvider    

    include SemanticLogger::Loggable

    UNITS = "imperial"

    def initialize(latitude, longitude)
      @latitude = latitude
      @longitude = longitude
    end

    # Fetches the current weather data for the initialized location.
    def get_weather(exclude: 'minutely,hourly,daily,alerts')
      query = build_query(@latitude, @longitude, exclude)
      responise = perform_query(query)
      response = OPEN_WEATHER_CLIENT.class.get('/onecall', query: query)
      
      response.parsed_response
    rescue => e
      logger.error "Error fetching current weather: #{e.message}"
      {}
    end

    # Fetches the weather forecast data for the initialized location.
    def forecast
      get_weather(exclude: nil)
    end

    private

    # Constructs a query hash for the OpenWeather API requests.
    #
    # @param latitude [Float] the latitude of the location
    # @param longitude [Float] the longitude of the location
    # @param units [String] the units of measurement ('metric', 'imperial', etc.)
    # @param exclude [String] a comma-separated list of weather data to exclude
    # @return [Hash] the constructed query hash
    def build_query(latitude, longitude, exclude)
      logger.info "Building query for lat: #{latitude}, lon: #{longitude}, units: #{UNITS}"
      query = {
        lat: latitude,
        lon: longitude,
        exclude: exclude,
        units: UNITS,
        appid: OPEN_WEATHER_CLIENT.instance_variable_get(:@api_key)
      }.compact
      logger.info "Query: #{query}"
      query
    end

    def perform_query(query)
      response = OPEN_WEATHER_CLIENT.class.get('/onecall', query: query)
      log_response(response)
    end

    # Logs the response received from the OpenWeather API.
    #
    # @param response [HTTParty::Response] the response object from the OpenWeather API
    # @param context [String] the context for the log message ('Current Weather' or 'Forecast')
    # @return [HTTParty::Response] the response object to chain actions on response
    def log_response(response)
      if response.success?
        logger.info "Weather data fetched successfully."
      else
        logger.error "Weather data fetch failed: #{response.code} - #{inspect(response)}"
      end
      response
    end
  end
end

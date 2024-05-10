module Weather
  class WeatherProvider
    include SemanticLogger::Loggable

    # WeatherProvider is responsible for fetching current weather and forecast data.
    # I coded it against OpenWeather API.
    #
    # The "enterprise tradeoff" thought here is that i didn't go through the trouble of creating
    # an interface, but am implementing the specific instance for OpenWeather inside a class that could
    # later become the interface name.  That way I can easily later forklift this to WeatherProviderOpenWeather 
    # and replace the contents of WeatherProvider as a base class with an interface.  It is not a perfect
    # tradeoff, but I am hoping it's ok for this takehome.
    #
    # It provides methods to retrieve the current weather conditions and the weather forecast for a specific location.
    #
    # Usage:
    #   provider = WeatherProvider.new
    #   current_weather = provider.current_weather(latitude: 37.7749, longitude: -122.4194, units: 'imperial')
    #   forecast = provider.forecast(latitude: 37.7749, longitude: -122.4194, units: 'imperial')
    #
    # Dependencies:
    #   - SemanticLogger: for logging
    #   - HTTParty: for making HTTP requests to the OpenWeather API
    #   - OPEN_WEATHER_CLIENT: a configured HTTParty client for the OpenWeather API


    # Fetches the current weather data for a specific location.
    #
    # @param latitude [Float] the latitude of the location
    # @param longitude [Float] the longitude of the location
    # @param units [String] the units of measurement ('metric', 'imperial', etc.)
    # @return [Hash] a hash containing the current weather data
    def current_weather(latitude:, longitude:, units: 'imperial')
      logger.info "Fetching current weather for lat: #{latitude}, lon: #{longitude}, units: #{units}"
      query = build_query(latitude, longitude, units, exclude: 'minutely,hourly,daily,alerts')
      logger.info "Query: #{query}"
      response = OPEN_WEATHER_CLIENT.class.get('/onecall', query: query)
      log_response(response, "Current Weather")
      response.parsed_response
    rescue => e
      logger.error "Error fetching current weather: #{e.message}"
      {}
    end

    # Fetches the weather forecast data for a specific location.
    #
    # @param latitude [Float] the latitude of the location
    # @param longitude [Float] the longitude of the location
    # @param units [String] the units of measurement ('metric', 'imperial', etc.)
    # @return [Hash] a hash containing the weather forecast data
    def forecast(latitude:, longitude:, units: 'imperial')
      logger.info "Fetching forecast for lat: #{latitude}, lon: #{longitude}, units: #{units}"
      query = build_query(latitude, longitude, units)
      logger.info "Query: #{query}"

      response = OPEN_WEATHER_CLIENT.class.get('/onecall', query: query)
      log_response(response, "Forecast")
      response.parsed_response
    rescue => e
      logger.error "Error fetching forecast: #{e.message}"
      {}
    end

    private

    # Constructs a query hash for the OpenWeather API requests.
    #
    # @param latitude [Float] the latitude of the location
    # @param longitude [Float] the longitude of the location
    # @param units [String] the units of measurement ('metric', 'imperial', etc.)
    # @param exclude [String] a comma-separated list of weather data to exclude
    # @return [Hash] the constructed query hash
    def build_query(latitude, longitude, units, exclude: nil)
      logger.info "Building query for lat: #{latitude}, lon: #{longitude}, units: #{units}"
      {
        lat: latitude,
        lon: longitude,
        units: units,
        exclude: exclude,
        appid: OPEN_WEATHER_CLIENT.instance_variable_get(:@api_key)
      }.compact
    end

    # Logs the response received from the OpenWeather API.
    #
    # @param response [HTTParty::Response] the response object from the OpenWeather API
    # @param context [String] the context for the log message ('Current Weather' or 'Forecast')
    def log_response(response, context)
      if response.success?
        logger.info "#{context} data fetched successfully."
      else
        logger.error "#{context} data fetch failed: #{response.code} - #{inspect(response)}"
      end
    end
  end
end

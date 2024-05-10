module Weather
  class WeatherProvider
    include SemanticLogger::Loggable
    # Fetches the current weather data for a specific location.
    #
    # @param latitude [Float] the latitude of the location
    # @param longitude [Float] the longitude of the location
    # @param units [String] the units of measurement ('metric', 'imperial', etc.)
    # @return [Hash] a hash containing the current weather data
    def current_weather(latitude:, longitude:, units: 'metric')
      logger.info "Fetching current weather for lat: #{latitude}, lon: #{longitude}"
      query = build_query(latitude, longitude, units, exclude: 'minutely,hourly,daily,alerts')
      logger.info "Query: #{query}"
      response = OPEN_WEATHER_CLIENT.class.get('/onecall', query: query)
      log_response(response, "Current Weather")
      response
    rescue => e
      {}
    end

    # Fetches the weather forecast data for a specific location.
    #
    # @param latitude [Float] the latitude of the location
    # @param longitude [Float] the longitude of the location
    # @param units [String] the units of measurement ('metric', 'imperial', etc.)
    # @return [Hash] a hash containing the weather forecast data
    def forecast(latitude:, longitude:, units: 'metric')
      logger.info "Fetching forecast for lat: #{latitude}, lon: #{longitude}"
      query = build_query(latitude, longitude, units)
      logger.info "Query: #{query}"

      response = OPEN_WEATHER_CLIENT.class.get('/onecall', query: query)
      log_response(response, "Forecast")
      response
    rescue => e
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
      logger.info "Building query for lat: #{latitude}, lon: #{longitude}"
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

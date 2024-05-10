module Weather
  # WeatherService is responsible for retrieving weather data for a given location using
  # the read-through cache pattern.
  #
  # It utilizes the WeatherProvider to fetch the data and the WeatherFetcher to tell the
  # FetchingCacheService how handle fetching and cacheing.
  #
  # Usage:
  #   weather_service = WeatherService.new
  #   weather_data = weather_service.get_weather(latitude: 37.7749, longitude: -122.4194)
  #
  # Dependencies:
  #   - WeatherProvider: Provides the actual weather data fetching functionality.
  #   - WeatherFetcher: Handles caching of the weather data.
  #   - Cache::FetchingCacheService: Provides caching functionality.
  #   - SemanticLogger: For logging purposes.
  class WeatherService
    include SemanticLogger::Loggable

    # Initializes a new instance of the WeatherService.
    #
    # @return [WeatherService] The initialized WeatherService instance.
    def initialize
      @weather_provider = WeatherProvider.new
    end

    # Retrieves the weather data for the given latitude and longitude.
    #
    # @param latitude [Float] The latitude of the location.
    # @param longitude [Float] The longitude of the location.
    # @return [Hash] The weather data for the specified location.
    def get_weather(latitude:, longitude:)
      logger.info "Looking up weather for lat: #{latitude}, lon: #{longitude}"
      weather_fetcher = WeatherFetcher.new(latitude, longitude, @weather_provider)
      Cache::FetchingCacheService.fetch_or_store(weather_fetcher)
    end
  end
end
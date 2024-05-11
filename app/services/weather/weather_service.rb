module Weather
  # WeatherService is responsible for retrieving weather data for a given location using
  # the read-through cache pattern.
  #
  # It selects 
  #   - the key strategy: currently postal, geocache implemented and available
  #   - the weather provider: currently OpenWeatherMap
  #   - the cache service: currently FetchingCacheServer using Redis 
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

    # Retrieves the weather data for the given latitude and longitude.
    #
    # @param latitude [Float] The latitude of the location.
    # @param longitude [Float] The longitude of the location.
    # @param postal_code [String] Possibly used for cacheing
    # @return [Hash] The weather data for the specified location.
    def get_weather(latitude:, longitude:, postal_code:)
      logger.info "Looking up weather for lat: #{latitude}, lon: #{longitude}"

      weather_provider = WeatherProviderOpenWeather.new(latitude, longitude)
      logger.info "have new weather provider"

      if postal_code.nil?
        # postal code not a reliable cache strategy for many consumer lookups like "Topeka, KS"
        # backup strategy is to use a ~2.4km x 3.2km geohash (precision 5)
        cache_key = "weather_geohash:#{GeoHash.encode(latitude, longitude, 5)}"
      else
        cache_key = "weather_postal_code:#{postal_code}"
      end

      logger.info "have new cache key #{cache_key}"
      weather_fetcher = WeatherFetcher.new(weather_provider, cache_key)
      logger.info "have new weather fetcher"
      weather = Cache::FetchingCacheService.fetch_or_store(weather_fetcher)
      logger.info "have new weather data #{weather}"
      weather
    end
  end
end
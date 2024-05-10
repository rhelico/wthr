module Weather
  # WeatherFetcher is responsible for fetching weather data from an external weather provider
  # based on the provided latitude and longitude coordinates.
  #
  # It implements the Cache::BaseFetcher interface, which provides a common interface for
  # fetching and caching data.
  #
  # The weather data is fetched from the specified weather provider.
  # The cache key is generated based on the latitude and longitude coordinates using the GeoHash
  # algorithm, which ensures that nearby coordinates have similar cache keys. 
  #
  # Yay!
  #
  # The CacheService will use the cache key to store and retrieve the weather data from the cache,
  # ...and check to see if the data is already cached. It's a read-through cache so will use this
  # ...implementation of BaseFetcher to fetch the data if it's not already cached. 
  #
  # Usage:
  #   weather_fetcher = WeatherFetcher.new(latitude, longitude, weather_provider)
  #   weather_data = Cache::FetchingCacheService.fetch_or_store(weather_fetcher)
  #
  # Dependencies:
  #   - Cache::BaseFetcher
  #   - SemanticLogger
  #   - GeoHash (for generating cache keys)
  #   - Weather provider (e.g., OpenWeatherMap, DarkSky)
  # Testing:
  #   - Logging that is inspected by tests has messages prefixed with "TESTABLE:"
  #     If you want different logging, you can change the test or leave it unchanged
  #     and add new logging that isn't in conflict with the test.
  class WeatherFetcher
    include Cache::BaseFetcher
    include SemanticLogger::Loggable

    def initialize(latitude, longitude, weather_provider)
      logger.info "Initializing WeatherFetcher"
      @latitude = latitude
      @longitude = longitude
      @weather_provider = weather_provider
    end

    def get_key
      logger.info "TESTABLE: Generating cache key for lat: #{@latitude}, lon: #{@longitude}"
      "weather:#{GeoHash.encode(@latitude, @longitude, 5)}"
    end

    def fetch
      logger.info "TESTABLE: Fetching weather for lat: #{@latitude}, lon: #{@longitude}"
      @weather_provider.current_weather(latitude: @latitude, longitude: @longitude).to_h
    end
  end
end

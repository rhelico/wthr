module Weather
  # WeatherFetcher is responsible for fetching weather data from an external weather provider
  # based on the provided latitude and longitude coordinates.
  #
  # It implements the Cache::BaseFetcher interface, which provides a common interface for
  # fetching and caching data.
  #
  # The weather data is fetched from the specified weather provider.
  # The cache key is passed in and on demand from the cache service is presented to cach fetched data.
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
  class WeatherFetcher
    include Cache::BaseFetcher
    include SemanticLogger::Loggable

    def initialize(weather_provider, cache_key)
      logger.info "Initializing WeatherFetcher"
      @weather_provider = weather_provider
      @key = cache_key
    end

    def get_key
      @key
    end

    def fetch
      @weather_provider.forecast.to_h
    end
  end
end

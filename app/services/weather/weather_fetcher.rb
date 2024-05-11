module Weather
  # WeatherFetcher is responsible for fetching weather data from an external provider.
  # This class adheres to the Cache::BaseFetcher interface to facilitate caching of the fetched data.
  #
  # Weather data retrieval is performed using the weather provider supplied at init, and a pre-defined cache key 
  # - also provided at init - is utilized for storing and retrieving data from the cache. 
  # This implementats a read-through caching strategy, fetching data from the provider only 
  # if it is not available in the cache. 
  #
  # Usage:
  #   weather_fetcher = WeatherFetcher.new(weather_provider, cache_key)
  #   weather_data = Cache::FetchingCacheService.fetch_or_store(weather_fetcher)
  #
  # Dependencies:
  #   - Cache::BaseFetcher: Interface for objects that fetch data and provide a cache key.
  #   - SemanticLogger: Used for logging internal operations.
  #   - Weather provider: External service like OpenWeatherMap or DarkSky.
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

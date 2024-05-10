require 'semantic_logger'
require 'redis'

module Cache
  # This module serves as a read-through caching layer
  # Implemented to use Redis as the caching mechanism.
  # It is generic via the use of the Cache::BaseFetcher interface.  This allows
  # for the implementation of different data fetching and key-ing strategies.
  #
  # Usage:
  #   # Initialize a data fetcher object
  #   data_fetcher = SomeDataFetcher.new(some_parameters)
  #
  #   # Fetch data using the FetchingCacheService, which either returns cached data or fetches
  #   # and caches fresh data if not already cached.
  #   data = Cache::FetchingCacheService.fetch_or_store(data_fetcher)
  #
  # Dependencies:
  #   - Redis: Used for storing and retrieving cached data.
  #   - SemanticLogger: Provides logging capabilities to trace and debug the caching process.
  #   - Rails.application.config.cache_store: Expected to be configured with appropriate parameters
  #     like Redis URL for connecting to the Redis instance.

  module FetchingCacheService
    extend self

    LOGGER = SemanticLogger[self]

    # Attempts to fetch data from cache using a provided data fetcher object. If the data
    # is not available in the cache, it fetches from the data source and stores it in the cache.
    #
    # @param data_fetcher [Object] An object responsible for fetching data and providing a unique cache key.
    # @return [Object] Cached or freshly fetched data.
    def fetch_or_store(data_fetcher)
      key = data_fetcher.get_key
      LOGGER.info "key: #{key}"

      # Fetch Redis configuration from Rails
      redis_url = Rails.application.config.cache_store.last[:url]
      LOGGER.info "Redis URL: #{redis_url}"

      # Initialize the Redis client
      redis = Redis.new(url: redis_url)
      LOGGER.info "Redis client: #{redis.inspect}"

      cached_data = redis.get(key)
      LOGGER.info "Cached data: #{cached_data}"

      if cached_data.present?
        JSON.parse(cached_data)
      else
        fresh_data = data_fetcher.fetch
        redis.setex(key, 30.minutes.to_i, fresh_data.to_json)
        fresh_data
      end
    end
  end
end

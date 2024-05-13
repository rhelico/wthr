require 'semantic_logger'
require 'redis'

module Cache
  # Provides a read-through caching mechanism using Redis. This service is designed to work
  # with any object that follows the Cache::BaseFetcher interface, which requires methods
  # for `get_key` and `fetch`. This design allows the use of different data fetching strategies
  # and makes the caching mechanism adaptable to various needs.
  #
  # Usage:
  #   # Initialize a data fetcher object
  #   data_fetcher = SomeDataFetcher.new(some_parameters)
  #   # Retrieve data, fetching it from the source and caching it if not already cached
  #   data = Cache::FetchingCacheService.fetch_or_store(data_fetcher)
  #
  # Dependencies:
  #   - Redis: Utilized for caching data.
  #   - SemanticLogger: Used for logging service operations and debugging.
  #   - Rails.application.config.cache_store: Must be configured to include the Redis URL.
  module FetchingCacheService
    extend self

    LOGGER = SemanticLogger[self]

    # Fetches data from cache or directly from the data source - via the fetcher - if not available in cache.
    # Caches the fresh data if it is fetched from the source.
    #
    # @param data_fetcher [Object] An object that knows how to fetch data and generate a cache key.
    # @return [Hash] Data retrieved from the cache or fetched fresh, with an added "cached" key indicating the source.
    
    def fetch_or_store(data_fetcher)
      key = data_fetcher.get_key
      LOGGER.info "key: #{key}"

      redis = initialize_redis_client

      cached_data = redis.get(key)
      LOGGER.info "Cached data: #{cached_data}"

      if cached_data.present?
        JSON.parse(cached_data)
      else
        fresh_data = data_fetcher.fetch
        cache_data = fresh_data
                      .dup
                      .merge("cached" => "true") 
                      .to_json
        redis.setex(key, 30.minutes.to_i, cache_data)
        redis.set('last_cache_update', Time.now.to_s)
        fresh_data
      end
    end
    # Fetches all keys matching a pattern
    def find_keys(pattern = '*')
      redis = initialize_redis_client
      return [] unless redis

      cursor = "0"
      keys = []
      loop do
        cursor, found_keys = redis.scan(cursor, match: pattern, count: 1000)
        keys.concat(found_keys)
        break if cursor == "0"
      end
      keys
    end

    # Clears the entire cache or specific keys
    def clear_cache(pattern = '*')
      redis = initialize_redis_client
      return unless redis

      keys = find_keys(pattern)
      keys.each { |key| redis.del(key) }
    end

    # Get the last cache update time
    def last_cache_time
      redis = initialize_redis_client
      return nil unless redis

      redis.get('last_cache_update')
    end

    private

    def initialize_redis_client
      # Fetch Redis configuration from Rails
      redis_url = Rails.application.config.cache_store.last[:url]
      LOGGER.info "Redis URL: #{redis_url.inspect}"

      # Initialize the Redis client
      redis = Redis.new(url: redis_url)
      LOGGER.info "Redis client: #{redis.inspect}"
      redis
    end
  end
end

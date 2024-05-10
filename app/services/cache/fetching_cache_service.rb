require 'semantic_logger'
require 'redis'

module Cache
  module FetchingCacheService
    extend self

    LOGGER = SemanticLogger[self]

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

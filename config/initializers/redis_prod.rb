return unless Rails.env.production?
require 'redis'
# $redis = Redis.new(url: ENV['REDIS_URL'])

Rails.application.config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  read_timeout: 20.0, # 20 seconds
  connect_timeout: 10.0, # 10 seconds
  reconnect_attempts: 3
}
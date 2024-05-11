require 'redis'
require 'docker'

return unless Rails.env.production?

$redis = Redis.new(url: ENV['REDIS_URL'])
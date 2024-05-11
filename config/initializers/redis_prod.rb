return unless Rails.env.production?
require 'redis'
$redis = Redis.new(url: ENV['REDIS_URL'])
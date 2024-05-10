require 'redis'
require 'docker'

begin
  Docker.options[:read_timeout] = 30 * 3 # 3 minutes

  redis_container_name = 'redis-simple'
  redis_port = 6379

  # Fetch the running Redis container
  running_container = Docker::Container.all(all: true).find do |container|
    labels = container.info['Labels']
    labels && labels['weather-app'] == 'simple-redis'
  end

  if running_container
    puts "Redis container found: #{running_container.info['Names'].first}"
    Rails.application.config.cache_store = :redis_cache_store, {
      url: "redis://localhost:#{redis_port}/0",
      read_timeout: 20.0, # 20 seconds
      connect_timeout: 10.0, # 10 seconds
      reconnect_attempts: 3
    }

    puts "Redis connection initialized"
  else
    puts "No Redis container running."
  end
rescue Excon::Error::Socket => e
  puts "Error connecting to Docker socket: #{e.message}"
end

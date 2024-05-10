require 'docker'

Docker.options[:read_timeout] =  5 # 5 seconds

# Create a Docker network for Redis cluster
network = Docker::Network.get('redis-cluster') rescue Docker::Network.create('redis-cluster')

# Check if Redis cluster containers are running
redis_containers = ['redis-node-1', 'redis-node-2', 'redis-node-3'].map do |name|
  Docker::Container.get(name) rescue nil
end.compact

unless redis_containers.all?(&:running?)
  puts "Starting Redis cluster containers..."

  # Stop and remove any existing Redis cluster containers
  redis_containers.each do |container|
    container.stop
    container.remove
  end

  # Pull the Redis image
  Docker::Image.create('fromImage' => 'redis')

  # Start the Redis cluster containers
  redis_containers = ['redis-node-1', 'redis-node-2', 'redis-node-3'].map.with_index do |name, index|
    container = Docker::Container.create(
      'Image' => 'redis',
      'HostConfig' => {
        'PortBindings' => {
          "#{7000 + index}/tcp" => [{}]
        },
        'NetworkMode' => network.id
      },
      'Name' => name,
      'Cmd' => ["redis-server", "--cluster-enabled=yes", "--cluster-node-timeout=5000", "--appendonly=yes", "--cluster-config-file=node-#{index + 1}.conf"]
    )
    container.start
    container
  end

  # Create the Redis cluster
  cluster_ips = redis_containers.map { |container| "#{container.json['NetworkSettings']['IPAddress']}:#{7000 + redis_containers.index(container)}" }
  Docker::Container.get('redis-node-1').exec(['redis-cli', '--cluster', 'create', *cluster_ips, '--cluster-replicas', '0'])
end

# Set environment variables for connecting to the Redis cluster
ENV['REDIS_URL'] = "redis://#{redis_containers.map { |container| "#{container.json['NetworkSettings']['IPAddress']}:#{7000 + redis_containers.index(container)}" }.join(',')}"
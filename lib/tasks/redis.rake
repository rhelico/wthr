namespace :redis do
  desc "Setup a simple Redis container using Docker"
  task :setup do
    Docker.options[:read_timeout] = 3 * 60 # 3 minutes

    begin
      # Fetch or create the network
      network = Docker::Network.get('redis-network')
    rescue Docker::Error::NotFoundError
      network = Docker::Network.create('redis-network')
    end

    redis_container_name = 'redis-simple'
    redis_port = 6379

    # Stop and remove existing Redis container
    begin
      container = Docker::Container.get(redis_container_name)
      puts "Removing old container: #{redis_container_name}"
      container.stop rescue nil
      container.remove(force: true) rescue nil
    rescue Docker::Error::NotFoundError
      # Container doesn't exist, no need to remove
    end

    # Prune unused Redis Docker containers
    puts "Pruning unused Redis Docker containers..."
    Docker::Container.all(all: true).each do |container|
      if container.info['Names'].first.include?(redis_container_name)
        begin
          puts "Pruning container: #{container.info['Names'].first}"
          container.stop rescue nil
          container.remove(force: true) rescue nil
        rescue Docker::Error::NotFoundError
          # Container doesn't exist, no need to remove
        end
      end
    end
    puts "Pruning completed."

    # Pull the latest Redis image
    Docker::Image.create('fromImage' => 'redis:latest')

    # Start new Redis container
    container = Docker::Container.create(
      'Image' => 'redis:latest',
      'HostConfig' => {
        'PortBindings' => {
          "#{redis_port}/tcp" => [{ 'HostPort' => "#{redis_port}" }]
        },
        'NetworkMode' => network.id
      },
      'ExposedPorts' => {
        "#{redis_port}/tcp" => {}
      },
      'Labels' => {
        'weather-app' => 'simple-redis',
        'weather-role' => 'redis-simple'
      },
      'Name' => redis_container_name,
      'Cmd' => ['redis-server', '--appendonly', 'yes']
    )
    container.start
    puts "Started Redis container: #{redis_container_name} (Port: #{redis_port})"

    puts "\nDocker containers (all):"
    Docker::Container.all(all: true).each do |container|
      puts "- #{container.info['Names'].first}: #{container.json['State']['Status']}"
    end

    # Show Docker images
    puts "\nDocker images:"
    Docker::Image.all.each do |image|
      puts "- #{image.info['RepoTags'].join(', ')}"
    end
  rescue Excon::Error::Socket => e
    puts "Error connecting to Docker socket: #{e.message}"
  end
end

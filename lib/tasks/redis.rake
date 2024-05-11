namespace :redis do
  desc "Setup and start a simple Redis container using Docker"
  task :setup do
    Docker.options[:read_timeout] = 180 # 3 minutes in seconds

    # Ensure the necessary network exists
    network = Docker::Network.all.find { |n| n.info['Name'] == 'redis-network' } || Docker::Network.create('redis-network')

    redis_container_name = 'redis-simple'
    redis_port = 6379

    # Attempt to get the existing container if it exists, stop and remove it
    begin
      container = Docker::Container.get(redis_container_name)
      puts "Stopping and removing existing container: #{redis_container_name}"
      container.stop
      container.remove
    rescue Docker::Error::NotFoundError
      puts "No existing container to remove."
    end

    # Pull the latest Redis image
    puts "Pulling the latest Redis image..."
    Docker::Image.create('fromImage' => 'redis:latest')

    # Start a new Redis container
    puts "Starting new Redis container..."
    container = Docker::Container.create(
      'Image' => 'redis:latest',
      'HostConfig' => {
        'PortBindings' => { "#{redis_port}/tcp" => [{ 'HostPort' => redis_port.to_s }] },
        'NetworkMode' => network.id
      },
      'ExposedPorts' => { "#{redis_port}/tcp" => {} },
      'Labels' => { 'weather-app' => 'simple-redis', 'weather-role' => 'redis-simple' },
      'Name' => redis_container_name,
      'Cmd' => ['redis-server', '--appendonly', 'yes']
    )
    container.start
    puts "Started Redis container: #{redis_container_name} on Port: #{redis_port}"

    # Optional: Display all Docker containers
    puts "\nListing all Docker containers:"
    Docker::Container.all(all: true).each do |c|
      puts "- #{c.info['Names'].first}: #{c.json['State']['Status']}"
    end
  end
end

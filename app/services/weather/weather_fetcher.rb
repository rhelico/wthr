module Weather
  class WeatherFetcher
    include Cache::BaseFetcher
    include SemanticLogger::Loggable

    def initialize(latitude, longitude, weather_provider)
      logger.info "Initializing WeatherFetcher"
      @latitude = latitude
      @longitude = longitude
      @weather_provider = weather_provider
    end

    def get_key
      logger.info "Generating cache key for lat: #{@latitude}, lon: #{@longitude}"
      "weather:#{GeoHash.encode(@latitude, @longitude, 5)}"
    end

    def fetch
      logger.info "Fetching weather for lat: #{@latitude}, lon: #{@longitude}"
      @weather_provider.current_weather(latitude: @latitude, longitude: @longitude).to_h
    end
  end
end

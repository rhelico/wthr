module Weather
  class WeatherService
    include SemanticLogger::Loggable
    def initialize
      @weather_provider = WeatherProvider.new
    end

    def get_weather(latitude:, longitude:)
      logger.info "Looking up weather for lat: #{latitude}, lon: #{longitude}"
      weather_fetcher = WeatherFetcher.new(latitude, longitude, @weather_provider)
      Cache::FetchingCacheService.fetch_or_store(weather_fetcher)
    end
  end
end
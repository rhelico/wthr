module Weather
  # The BaseWeatherProvider module defines the necessary interface for WeatherProviders  
  # to work with the WeatherService class.
  #
  # The main method provided by this module, `get_weather`, should return the current weather
  #
  # Implementations of BaseFetcher are expected to provide specific logic for fetching data from
  # external sources and generating unique cache keys. This design allows the caching system to
  # remain agnostic of the data source specifics while still being able to perform its function
  # effectively.
  #
  # Expected methods:
  #   - get_weather: Returns current weather by default.  
  #      Override exclude to get 'minutely, hourly, daily, alerts'.
  #
  # Example Usage:
  #   class WeatherFetcher < BaseFetcher
  #     def get_key
  #       "weather_#{latitude}_#{longitude}"
  #     end
  #
  #     def fetch
  #       # Logic to fetch weather data
  #     end
  #   end
  #
  module BaseWeatherProvider
    def get_weaather(exclude: 'minutely,hourly,daily,alerts')
      raise NotImplementedError, "#{self.class.name} must implement #get_weather"
    end
  end
end
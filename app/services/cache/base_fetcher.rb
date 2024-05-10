module Cache
  # The BaseFetcher module acts as an interface for all fetcher classes that will be used in
  # conjunction with the caching system. 
  #
  # Implementations of BaseFetcher are expected to provide specific logic for fetching data from
  # external sources and generating unique cache keys. This design allows the caching system to
  # remain agnostic of the data source specifics while still being able to perform its function
  # effectively.
  #
  # Expected methods:
  #   - get_key: Should return a unique string that represents the cache key under which the
  #              fetched data will be stored. This key must uniquely identify the data set
  #              retrieved by the fetch method.
  #   - fetch: Should handle the retrieval of data from an external source. The specifics of
  #            this retrieval process (e.g., API calls, database queries) are determined by
  #            the specific fetcher implementation.
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
  module BaseFetcher
    def get_key
      raise NotImplementedError, "#{self.class.name} must implement #get_key"
    end

    def fetch
      raise NotImplementedError, "#{self.class.name} must implement #fetch"
    end
  end
end
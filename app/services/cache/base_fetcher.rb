module Cache
  module BaseFetcher
    def get_key
      raise NotImplementedError, "#{self.class.name} must implement #get_key"
    end

    def fetch
      raise NotImplementedError, "#{self.class.name} must implement #fetch"
    end
  end
end
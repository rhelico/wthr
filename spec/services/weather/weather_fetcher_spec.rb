require 'rails_helper'

RSpec.describe Weather::WeatherFetcher do
  let(:weather_provider) { instance_double('WeatherProvider') }
  let(:cache_key) { "weather:9q8yy" }  # Assuming the cache_key includes the geohash

  describe '#get_key' do
    subject(:weather_fetcher) { described_class.new(weather_provider, cache_key) }

    it 'generates the correct cache key' do
      expect(weather_fetcher.get_key).to eq(cache_key)
    end
  end

  describe '#fetch' do
    let(:weather_data) { { temperature: 72.5, humidity: 0.3, description: 'Sunny' } }
    subject(:weather_fetcher) { described_class.new(weather_provider, cache_key) }

    before do
      allow(weather_provider).to receive(:forecast).and_return(weather_data)
    end

    it 'fetches weather data from the weather provider' do
      expect(weather_fetcher.fetch).to eq(weather_data)
    end
  end
end

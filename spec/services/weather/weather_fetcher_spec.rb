require 'rails_helper'

RSpec.describe Weather::WeatherFetcher do
  let(:latitude) { 37.7749 }
  let(:longitude) { -122.4194 }
  let(:expected_geohash) { '9q8yy' }
  let(:weather_provider) { instance_double('WeatherProvider') }

 

  describe '#get_key' do
    subject(:weather_fetcher) { described_class.new(latitude, longitude, weather_provider) }

    it 'generates the correct cache key' do
      expect(weather_fetcher.get_key).to eq("weather:#{expected_geohash}")
    end
  end

  describe '#fetch' do
    let(:weather_data) { { temperature: 72.5, humidity: 0.3, description: 'Sunny' } }
    subject(:weather_fetcher) { described_class.new(latitude, longitude, weather_provider) }

    before do
      allow(weather_provider).to receive(:current_weather).with(latitude: latitude, longitude: longitude).and_return(double(to_h: weather_data))
    end

    it 'fetches weather data from the weather provider' do
      expect(weather_fetcher.fetch).to eq(weather_data)
    end
  end
end
require 'rails_helper'

RSpec.describe Weather::WeatherService do
  # Define the subject of the test
  subject(:weather_service) { described_class.new }

  describe '#get_weather' do
    let(:latitude) { 37.7749 }
    let(:longitude) { -122.4194 }
    let(:postal_code) { "94103" }
    let(:weather_data) { { 'temp' => 72.5, 'humidity' => 0.3, 'description' => 'Sunny' } }
    let(:weather_provider) { instance_double(Weather::WeatherProviderOpenWeather) }
    let(:weather_fetcher) { instance_double(Weather::WeatherFetcher, get_key: 'key', fetch: weather_data) }

    before do
      allow(Weather::WeatherProviderOpenWeather).to receive(:new).and_return(weather_provider)
      allow(Weather::WeatherFetcher).to receive(:new).with(weather_provider, anything).and_return(weather_fetcher)
      allow(Cache::FetchingCacheService).to receive(:fetch_or_store).with(weather_fetcher).and_return(weather_data)
    end

    it 'initializes a weather provider and fetches weather data' do
      # Use the defined subject to call get_weather
      expect(weather_service.get_weather(latitude: latitude, longitude: longitude, postal_code: postal_code)).to eq(weather_data)
    end
  end
end

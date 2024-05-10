require 'rails_helper'

RSpec.describe Weather::WeatherService do
  subject(:weather_service) { described_class.new }

  describe '#initialize' do
    it 'initializes a new WeatherProvider' do
      expect(Weather::WeatherProvider).to receive(:new).and_call_original
      weather_service
    end
  end

  describe '#get_weather' do
    let(:latitude) { 37.7749 }
    let(:longitude) { -122.4194 }
    let(:weather_data) { { 'temp' => 72.5, 'humidity' => 0.3, 'description' => 'Sunny' } }
    let(:weather_fetcher) { instance_double(Weather::WeatherFetcher) }

    before do
      allow(Weather::WeatherFetcher).to receive(:new).and_return(weather_fetcher)
      allow(weather_fetcher).to receive(:get_key).and_return('weather_key')
      allow(weather_fetcher).to receive(:fetch).and_return(weather_data)
    end

    it 'creates a WeatherFetcher with the correct parameters' do
      expect(Weather::WeatherFetcher).to receive(:new).with(latitude, longitude, instance_of(Weather::WeatherProvider))
      weather_service.get_weather(latitude: latitude, longitude: longitude)
    end

    it 'fetches or stores the weather data using the Cache::FetchingCacheService' do
      expect(Cache::FetchingCacheService).to receive(:fetch_or_store).with(weather_fetcher).and_return(weather_data)
      weather_service.get_weather(latitude: latitude, longitude: longitude)
    end

    it 'returns the weather data' do
      expect(weather_service.get_weather(latitude: latitude, longitude: longitude)).to eq(weather_data)
    end
  end
end
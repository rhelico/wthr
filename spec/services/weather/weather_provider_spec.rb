require 'rails_helper'

RSpec.describe Weather::WeatherProvider do
  subject(:provider) { described_class.new }

  describe '#current_weather' do
    let(:latitude) { 37.7749 }
    let(:longitude) { -122.4194 }
    let(:units) { 'imperial' }
    let(:response_data) { { 'temp' => 72.5, 'humidity' => 0.3, 'description' => 'Sunny' } }

    before do
      response_double = double(parsed_response: response_data, success?: true)
      allow(OPEN_WEATHER_CLIENT).to receive_message_chain(:class, :get).and_return(response_double)
    end

    it 'fetches the current weather data' do
      expect(provider.current_weather(latitude: latitude, longitude: longitude, units: units)).to eq(response_data)
    end
  end

  describe '#forecast' do
    let(:latitude) { 37.7749 }
    let(:longitude) { -122.4194 }
    let(:units) { 'imperial' }
    let(:response_data) { { 'daily' => [{ 'temp' => { 'day' => 75.2 }, 'humidity' => 0.4, 'description' => 'Partly cloudy' }] } }

    before do
      response_double = double(parsed_response: response_data, success?: true)
      allow(OPEN_WEATHER_CLIENT).to receive_message_chain(:class, :get).and_return(response_double)
    end

    it 'fetches the weather forecast data' do
      expect(provider.forecast(latitude: latitude, longitude: longitude, units: units)).to eq(response_data)
    end
  end
end
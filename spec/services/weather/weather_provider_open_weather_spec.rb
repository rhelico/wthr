require 'rails_helper'

RSpec.describe Weather::WeatherProviderOpenWeather do
  let(:latitude) { 37.7749 }
  let(:longitude) { -122.4194 }
  subject(:provider) { described_class.new(latitude, longitude) }

  describe '#get_weather' do
    let(:response_data) do
      {
        'current' => { 'temp' => 72.5, 'humidity' => 0.3, 'description' => 'Sunny' },
        'daily' => [
          { 'dt' => (Date.today + 1).to_time.to_i, 'temp' => { 'day' => 75.2 }, 'humidity' => 0.4, 'description' => 'Partly cloudy' },
          { 'dt' => (Date.today + 2).to_time.to_i, 'temp' => { 'day' => 77.0 }, 'humidity' => 0.5, 'description' => 'Cloudy' }
        ]
      }
    end

    before do
      response_double = double('HTTParty::Response', parsed_response: response_data, success?: true)
      allow(OPEN_WEATHER_CLIENT).to receive_message_chain(:class, :get).and_return(response_double)
    end

    it 'fetches the current weather data' do
      expected_result = { 
        today: response_data['current'],
        tomorrow: response_data['daily'][0],
        next_day: response_data['daily'][1]
      }
      expect(provider.get_weather).to eq(expected_result)
    end
  end

  describe '#forecast' do
    before do
      allow(provider).to receive(:get_weather).and_return({ forecast: 'Data' })
    end

    it 'fetches the weather forecast data' do
      expect(provider.forecast).to eq({ forecast: 'Data' })
    end
  end
end

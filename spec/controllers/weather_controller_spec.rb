require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe 'GET #lookup' do
    let(:latitude) { 37.7749 }
    let(:longitude) { -122.4194 }
    let(:postal_code) { '94103' }
    let(:weather_service) { instance_double('Weather::WeatherService') }

    before do
      allow(Weather::WeatherService).to receive(:new).and_return(weather_service)
      allow(weather_service).to receive(:get_weather).with(latitude: latitude, longitude: longitude, postal_code: postal_code).and_return(weather_data)
    end

    context 'when weather service returns valid data' do
      let(:weather_data) { { temperature: 72.5, humidity: 0.3, description: 'Sunny' } }

      it 'returns a successful response' do
        get :lookup, params: { latitude: latitude, longitude: longitude, postalCode: postal_code }
        expect(response).to be_successful
      end

      it 'returns the expected JSON response' do
        get :lookup, params: { latitude: latitude, longitude: longitude, postalCode: postal_code }
        expected_response = { "description" => "Sunny", "humidity" => 0.3, "temperature" => 72.5 }
        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end

    context 'when weather service returns an error' do
      let(:error_message) { 'Failed to fetch weather data' }
      let(:weather_data) { { error: error_message } }

      it 'returns an unprocessable entity status' do
        get :lookup, params: { latitude: latitude, longitude: longitude, postalCode: postal_code }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the expected error response' do
        get :lookup, params: { latitude: latitude, longitude: longitude, postalCode: postal_code }
        expect(JSON.parse(response.body)).to eq({ 'error' => error_message })
      end
    end
  end
end

require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe 'GET #lookup' do
    let(:latitude) { 37.7749 }
    let(:longitude) { -122.4194 }
    let(:weather_service) { instance_double('Weather::WeatherService') }

    before do
      allow(Weather::WeatherService).to receive(:new).and_return(weather_service)
    end

    context 'when weather service returns valid data' do
      let(:weather_data) { { temperature: 72.5, humidity: 0.3, description: 'Sunny' } }

      before do
        allow(weather_service).to receive(:get_weather).with(latitude: latitude, longitude: longitude).and_return(weather_data)
        allow(controller.logger).to receive(:debug)
        get :lookup, params: { latitude: latitude, longitude: longitude }
      end

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'returns the expected JSON response' do
        expected_response = { "description" => "Sunny", "humidity" => 0.3, "temperature" => 72.5 }
        expect(JSON.parse(response.body)).to eq(expected_response)
      end

      it 'logs the latitude and longitude' do
        expect(controller.logger).to have_received(:debug).with("TESTABLE: Looking up weather for latitude: #{latitude}, longitude: #{longitude}")
      end
    end

    context 'when weather service returns an error' do
      let(:error_message) { 'Failed to fetch weather data' }
      let(:error_data) { { error: error_message } }

      before do
        allow(weather_service).to receive(:get_weather).with(latitude: latitude, longitude: longitude).and_return(error_data)
        allow(controller.logger).to receive(:error)
        get :lookup, params: { latitude: latitude, longitude: longitude }
      end

      it 'returns an unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the expected error response' do
        expect(JSON.parse(response.body)).to eq({ 'error' => error_message })
      end

      it 'logs the error' do
        expect(controller.logger).to have_received(:error).with('Error in WeatherService response', error: error_message)
      end
    end

    context 'when an unexpected error occurs' do
      let(:exception) { StandardError.new('Unexpected error') }

      before do
        allow(weather_service).to receive(:get_weather).with(latitude: latitude, longitude: longitude).and_raise(exception)
        allow(controller.logger).to receive(:error).with("TESTABLE: Exception fetching weather data", exception: exception)
        get :lookup, params: { latitude: latitude, longitude: longitude }
      end

      it 'returns an unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the expected error response' do
        expect(JSON.parse(response.body)).to eq({ 'error' => 'An unexpected error occurred while fetching weather data' })
      end

      it 'logs the exception' do
        expect(controller.logger).to have_received(:error).with("TESTABLE: Exception fetching weather data", exception: exception)
      end
    end
  end
end
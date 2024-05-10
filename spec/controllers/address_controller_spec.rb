require 'rails_helper'

RSpec.describe AddressesController, type: :controller do
  describe 'GET #autocomplete' do
    context 'with a valid query' do
      let(:query) { 'New York' }
      let(:geocoder_results) do
        [
          double('result', address: '123 Main St, New York, NY 10001', coordinates: [40.7128, -74.0060]),
          double('result', address: '456 Broadway, New York, NY 10002', coordinates: [40.7196, -73.9937])
        ]
      end
      let(:addresses) do
        [
          { "formatted_address" => "123 Main St, New York, NY 10001", "latitude" => 40.7128, "longitude" => -74.006 },
          { "formatted_address" => "456 Broadway, New York, NY 10002", "latitude" => 40.7196, "longitude" => -73.9937 }
        ]
      end

      before do
        allow_any_instance_of(Address::AddressService).to receive(:autocomplete).with(query).and_return(addresses)
        allow(controller.logger).to receive(:info)
        get :autocomplete, params: { query: query }
      end

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'returns the expected JSON response' do
        expect(JSON.parse(response.body)).to eq(addresses)
      end

      it 'logs the autocomplete query and results' do
        expect(controller.logger).to have_received(:info).with("TESTABLE: Received autocomplete query: #{query}")
        expect(controller.logger).to have_received(:info).with("TESTABLE: Address service results: #{addresses}")
      end
    end

    context 'with an empty query' do
      before do
        allow(controller.logger).to receive(:debug)
        get :autocomplete, params: { query: '' }
      end

      it 'returns an empty array' do
        expect(JSON.parse(response.body)).to eq([])
      end

      it 'logs the absence of a query' do
        expect(controller.logger).to have_received(:debug).with('No addresses yet')
      end
    end

    context 'when Geocoder raises an error' do
      let(:query) { 'Invalid query' }
      let(:geocoder_error) { StandardError.new('Geocoder error') }

      before do
        allow_any_instance_of(Address::AddressService).to receive(:autocomplete).with(query).and_raise(geocoder_error)
        allow(controller.logger).to receive(:error)
        get :autocomplete, params: { query: query }
      end

      it 'returns an empty array' do
        expect(JSON.parse(response.body)).to eq([])
      end

      it 'logs the error' do
        expect(controller.logger).to have_received(:error).with("Address service error: Geocoder error")
      end
    end
  end
end
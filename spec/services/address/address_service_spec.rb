require 'rails_helper'

RSpec.describe Address::AddressService do
  let(:address_provider) { instance_double('Address::AddressProvider') }
  let(:service) { described_class.new(address_provider) }

  describe '#autocomplete' do
    context 'when the query is valid' do
      let(:query) { 'New York, NY' }
      let(:geocoder_results) do
        [
          double('result', address: '123 Main St, New York, NY 10001', coordinates: [40.7128, -74.0060]),
          double('result', address: '456 Broadway, New York, NY 10002', coordinates: [40.7196, -73.9937])
        ]
      end
      let(:expected_results) do
        [
          { formatted_address: '123 Main St, New York, NY 10001', latitude: 40.7128, longitude: -74.0060 },
          { formatted_address: '456 Broadway, New York, NY 10002', latitude: 40.7196, longitude: -73.9937 }
        ]
      end

      before do
        allow(address_provider).to receive(:search).with(query).and_return(geocoder_results)
      end

      it 'returns the expected formatted results' do
        expect(service.autocomplete(query)).to eq(expected_results)
      end
    end

    context 'when the query is empty' do
      let(:query) { '' }

      before do
        allow(address_provider).to receive(:search).with(query).and_return([])
      end

      it 'returns an empty array' do
        expect(service.autocomplete(query)).to eq([])
      end
    end

    context 'when the address provider raises an error' do
      let(:query) { 'Invalid query' }
      let(:geocoder_error) { Geocoder::Error.new('Geocoder error') }

      before do
        allow(address_provider).to receive(:search).with(query).and_raise(geocoder_error)
      end

      it 'raises the Geocoder error' do
        expect { service.autocomplete(query) }.to raise_error(geocoder_error)
      end
    end
  end
end
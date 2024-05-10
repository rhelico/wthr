require 'rails_helper'

RSpec.describe Address::AddressProvider do
  let(:provider) { described_class.new }

  describe '#search' do
    context 'when the query is valid' do
      let(:query) { 'New York, NY' }
      let(:geocoder_results) do
        [
          double('result', address: '123 Main St, New York, NY 10001', coordinates: [40.7128, -74.0060]),
          double('result', address: '456 Broadway, New York, NY 10002', coordinates: [40.7196, -73.9937])
        ]
      end

      before do
        allow(Geocoder).to receive(:search).with(query).and_return(geocoder_results)
      end

      it 'returns the expected Geocoder results' do
        expect(provider.search(query)).to eq(geocoder_results)
      end
    end

    context 'when the query is empty' do
      let(:query) { '' }

      it 'returns an empty array' do
        expect(provider.search(query)).to eq([])
      end
    end

    context 'when Geocoder raises an error' do
      let(:query) { 'Invalid query' }
      let(:geocoder_error) { Geocoder::Error.new('Geocoder error') }

      before do
        allow(Geocoder).to receive(:search).with(query).and_raise(geocoder_error)
      end

      it 'raises the Geocoder error' do
        expect { provider.search(query) }.to raise_error(geocoder_error)
      end
    end
  end
end
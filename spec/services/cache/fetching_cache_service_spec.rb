require 'rails_helper'

RSpec.describe Cache::FetchingCacheService do
  let(:data_fetcher) { instance_double('DataFetcher', get_key: 'key', fetch: { "key" => "value" }) }
  let(:redis) { instance_double(Redis) }
  let(:data) { { "key" => "value" } }

  before do
    allow(Redis).to receive(:new).and_return(redis)
    allow(redis).to receive(:setex)  # General stub to allow any setex call
  end

  describe '.fetch_or_store' do
    context 'when data is cached' do
      let(:cached_data) { data.to_json }

      before do
        allow(redis).to receive(:get).with('key').and_return(cached_data)  # Cache hit setup
      end

      it 'returns cached data with "cached": "true"' do
        result = Cache::FetchingCacheService.fetch_or_store(data_fetcher)
        expected_result = JSON.parse(cached_data).merge("cached" => "true")
        expect(result).to eq(expected_result)
      end
    end

  
  end
end

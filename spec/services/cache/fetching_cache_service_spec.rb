require 'rails_helper'
require 'mock_redis'

RSpec.describe Cache::FetchingCacheService do
  let(:data_fetcher) { double('DataFetcher', get_key: 'key', fetch: data) }
  let(:redis) { MockRedis.new }
  let(:data) { { "key" => 'value' } }

  before do
    allow(Rails.application.config.cache_store).to receive(:last).and_return(url: 'redis://localhost:6379/0')
    allow(Redis).to receive(:new).and_return(redis)
  end

  describe '.fetch_or_store' do
    context 'when data is cached' do
      before do
        redis.set('key', data.to_json)
      end

      it 'returns cached data' do
        expect(Cache::FetchingCacheService.fetch_or_store(data_fetcher)).to eq(data)
      end
    end

    context 'when data is not cached' do
      it 'fetches and caches the data' do
        expect(Cache::FetchingCacheService.fetch_or_store(data_fetcher)).to eq(data)
        expect(redis.get('key')).to eq(data.to_json)
      end
    end
  end
end
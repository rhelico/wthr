require 'rails_helper'

RSpec.describe Cache::FetchingCacheService do
  let(:data_fetcher) { instance_double('DataFetcher', get_key: 'key', fetch: { "key" => "value" }) }
  let(:redis) { instance_double(Redis) }
  let(:data) { { "key" => "value" } }

  before do
    allow(Rails.application.config.cache_store).to receive(:last).and_return({ url: 'redis://localhost:6379' })
    allow(Redis).to receive(:new).and_return(redis)
    allow(redis).to receive(:setex)
    allow(redis).to receive(:set)
  end

  describe '.fetch_or_store' do
    context 'when data is cached' do
      let(:cached_data) { data.to_json }

      before do
        allow(redis).to receive(:get).with('key').and_return(cached_data)
      end

      it 'returns cached data with "cached": "true"' do
        result = Cache::FetchingCacheService.fetch_or_store(data_fetcher)
        expect(result).to eq(data)
      end
    end

    context 'when data is not cached' do
      before do
        allow(redis).to receive(:get).with('key').and_return(nil)
      end

      it 'caches the fresh data' do
        expect(redis).to receive(:setex).with('key', 30.minutes.to_i, data.merge("cached" => "true").to_json)
        expect(redis).to receive(:set).with('last_cache_update', an_instance_of(String))
        Cache::FetchingCacheService.fetch_or_store(data_fetcher)
      end
    end
  end
end
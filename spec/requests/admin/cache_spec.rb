require 'rails_helper'

RSpec.describe Admin::CacheController, type: :controller do
  describe 'GET #index' do
    it 'assigns cache keys and last cache time' do
      keys = ['key1', 'key2']
      last_cache_time = Time.now

      allow(Cache::FetchingCacheService).to receive(:find_keys).and_return(keys)
      allow(Cache::FetchingCacheService).to receive(:last_cache_time).and_return(last_cache_time)

      get :index

      expect(assigns(:cache_keys)).to eq(keys)
      expect(assigns(:last_cache_time)).to eq(last_cache_time)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'POST #clear' do
    it 'calls clear_cache method with the correct pattern' do
      pattern = 'pattern'
      allow(Cache::FetchingCacheService).to receive(:clear_cache)

      post :clear, params: { pattern: pattern }

      expect(Cache::FetchingCacheService).to have_received(:clear_cache).with(pattern)
    end

    it 'redirects to admin cache path with notice' do
      allow(Cache::FetchingCacheService).to receive(:clear_cache)
      post :clear

      expect(response).to redirect_to(admin_cache_path)
      expect(flash[:notice]).to eq('Cache successfully cleared.')
    end
  end
end

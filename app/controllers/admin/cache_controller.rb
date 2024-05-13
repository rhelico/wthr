class Admin::CacheController < ApplicationController
  def index
    @cache_keys = Cache::FetchingCacheService.find_keys(params[:search])
    @last_cache_time = Cache::FetchingCacheService.last_cache_time
  end

  def clear
    Cache::FetchingCacheService.clear_cache(params[:pattern])
    redirect_to admin_cache_path, notice: 'Cache successfully cleared.'
  end
end

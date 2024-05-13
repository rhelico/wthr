Rails.application.routes.draw do
  get 'addresses/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Application specific
   
  # home
  root "pages#index"

  # address lookup
  get 'addresses/autocomplete', to: 'addresses#autocomplete'
  resources :addresses, only: [:index]

  # weather lookup
  get 'weather/lookup', to: 'weather#lookup'

  # cache admin
  namespace :admin do
    get 'cache', to: 'cache#index'
    delete 'cache/clear', to: 'cache#clear', as: :clear_cache
  end

end

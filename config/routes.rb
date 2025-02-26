Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # Test endpoint
  get '/test', to: 'test#index'

  # Route for the body shops search
  get '/body_shops/search', to: 'body_shops#search'
end


Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :customers, only: [:index]
      resources :merchants, only: [:index, :show, :create]
      resources :items
    end
  end
end

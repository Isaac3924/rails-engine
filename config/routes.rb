Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :customers, only: [:index]
      resources :merchants, only: [:index, :show, :create] do
        resources :items, only: [:index], controller: "merchants/items" 
      end
      resources :items do
        resources :merchant, only: [:index], controller: "items/merchant"
      end
    end
  end
end

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'items/find', to: 'items#find'
      get 'items/find_all', to: 'items#find_all'
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

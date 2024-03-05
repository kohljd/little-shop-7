Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get "/", to: "application#welcome"

  resources :bulk_discounts, only: [:index, :show, :update, :new], via: :patch

  resources :merchants, only: [] do
    resources :dashboard, module: "merchant", only: [:index]
    resources :items, module: "merchant", except: [:destroy], via: [:patch]
    resources :invoices, module: "merchant", only: [:index, :show]
    resources :invoice_items, module: "merchant", only: [:update], via: [:patch]
  end

  resources :admin, only: [:index], controller: "admin_dashboard"

  namespace :admin do
    resources :merchants, except: [:destroy], via: [:patch]
    resources :invoices, only: [:index, :show, :update], via: [:patch]
  end
end

class NonFirefoxConstraint
  def matches?(request)
    request.user_agent !~ /Firefox/i
  end
end

Rails.application.routes.draw do
  constraints NonFirefoxConstraint.new do
    get "admin" => "admin#index"
    get "up" => "rails/health#show", as: :rails_health_check

    namespace :admin do
      resources :reports, only: [ :index ]
      resources :categories, only: [ :index ]
    end

    get "my-orders" => "users#orders", as: :my_orders
    get "my-items" => "users#line_items", as: :my_items

    resources :users do
      get :orders, on: :collection
      get :line_items, on: :collection
    end

    resources :products, path: "books" do
      delete :remove_image, on: :member
    end

    resource :session
    resources :passwords, param: :token

    get "categories/:id/books", to: "categories#books", as: :category_books, constraints: { id: /\d+/ }
    get "categories/:id/books", to: redirect("/"), constraints: { id: /[^0-9]+.*/ }
  end

  locale_pattern = I18n.available_locales.map(&:to_s).join("|")

  scope "(:locale)", locale: /#{locale_pattern}/ do
    root "store#index", as: "store_index", via: :all

    constraints NonFirefoxConstraint.new do
      resources :orders
      resources :line_items
      resources :carts
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :rails_pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

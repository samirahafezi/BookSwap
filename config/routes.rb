Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get "signup", to: "users#new", as: :signup
  post "signup", to: "users#create"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "books#index"

  resources :books do
    collection do
      get :browse
    end
    member do
      post :borrow, to: "borrows#borrow"
      post :return, to: "borrows#return"
    end
  end

  get "profile", to: "users#profile", as: :profile
  patch "profile", to: "users#update"

  get "my-borrowed-books", to: "borrows#my_borrowed_books", as: :my_borrowed_books
  get "borrowing-history", to: "borrows#borrowing_history", as: :borrowing_history
  get "my-books-borrowers", to: "borrows#my_books_borrowers", as: :my_books_borrowers

  resources :borrows, only: [] do
    resource :rating, only: %i[new create], controller: :ratings
  end
end

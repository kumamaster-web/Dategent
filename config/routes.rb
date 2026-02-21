Rails.application.routes.draw do
  # Sidekiq Web dashboard — restricted to admin user
  require "sidekiq/web"
  authenticate :user, ->(u) { u.email == "test@example.com" } do
    mount Sidekiq::Web => "/sidekiq"
  end

  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  # Dashboard (main landing page for authenticated users)
  resource :dashboard, only: [:show], controller: "dashboard"

  # Profile (singular resource — always current_user)
  resource :profile, only: [:show, :edit, :update]

  # User Preferences (singular resource — always current_user)
  resource :user_preference, only: [:show, :edit, :update]

  # Agent settings (singular resource — always current_user's agent)
  resource :agent, only: [:show, :edit, :update]

  # Matches
  resources :matches, only: [:index, :show]

  # Date Events
  resources :date_events, only: [:show] do
    member do
      patch :accept
      patch :decline
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path — authenticated users go to dashboard, guests go to sign in
  authenticated :user do
    root "dashboard#show", as: :authenticated_root
  end

  root to: redirect("/users/sign_in")
end

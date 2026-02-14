Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  # Profile (singular resource — always current_user)
  resource :profile, only: [:show, :edit, :update]

  # User Preferences (singular resource — always current_user)
  resource :user_preference, only: [:show, :edit, :update]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path — authenticated users go to profile, guests go to sign in
  authenticated :user do
    root "profiles#show", as: :authenticated_root
  end

  root to: redirect("/users/sign_in")
end

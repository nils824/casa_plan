Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[new create]

  resource :profile, only: %i[show edit update] do
    resource :password, only: %i[edit update], controller: "profile/passwords"
    resource :email, only: %i[edit update], controller: "profile/emails"
  end
  get "email_confirmations/:token", to: "email_confirmations#show", as: :email_confirmation

  resources :stays, only: %i[index show new create edit update] do
    member do
      patch :confirm
      patch :reject
      patch :withdraw
    end
  end
  resources :activities, only: :index

  namespace :admin do
    resources :users, only: %i[index edit update]
  end

  root "stays#index"

  get "up" => "rails/health#show", as: :rails_health_check
end

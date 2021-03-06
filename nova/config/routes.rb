# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'pages#root'
  get '/dashboard', to: 'dashboard#show'
  devise_for :users, controllers: { registrations: 'users/registrations', confirmations: 'users/confirmations' }

  namespace :api, defaults: { format: 'json' } do
    resource :user, only: %i[show update]
    resource :credit_card, only: %i[show create]
    resources :charges, only: %i[index create]
    resources :remit_requests, only: %i[index create] do
      member do
        post :accept
        post :reject
        post :cancel
      end
    end
  end
end

Rails.application.routes.draw do
  resources :accounts, only: [:index, :edit, :update]
  root to: 'dashboard#index'
  get 'trades/buy', to: 'trades#buy'
  get 'trades/sell', to: 'trades#sell'
  get 'trades/square_off', to: 'trades#square_off'
  get 'trades/reverse', to: 'trades#reverse'
end

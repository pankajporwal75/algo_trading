Rails.application.routes.draw do
  resources :accounts, only: [:index, :edit, :update, :show]
end

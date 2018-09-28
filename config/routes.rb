Rails.application.routes.draw do
  resources :accounts
  resources :clients do
    get :balance, on: :member
    post :transfer_money, on: :member
  end
end

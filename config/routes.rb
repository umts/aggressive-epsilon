Rails.application.routes.draw do

  resources :reservations, except: [:new, :edit] do
    post :update_item
  end
end

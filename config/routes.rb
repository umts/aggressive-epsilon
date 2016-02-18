Rails.application.routes.draw do

  namespace :v1 do
    resources :item_types, except: %i(new edit)
    resources :items, except: %i(new edit)
    resources :reservations, except: %i(new edit) do
      member { post :update_item }
    end
  end
end

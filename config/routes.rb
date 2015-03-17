Rails.application.routes.draw do
  #get 'home/index'

  resources :users do
    resources :game_users do
      resources :rations
      resources :games
      resources :cards
      resources :moves
    end
  end

  resources :games do
    resources :game_users do
      resources :rations
      resources :games
      resources :cards
      resources :moves
    end
    resources :positions
    resources :cards
    resources :game_cards
    resources :rations
    resources :rounds do
      resources :moves
    end
  end

  resources :cards do
    resources :games
    resources :users
  end

  resources :carddecks do
    resources :cards
  end

  resources :rations do
    resources :ingredients
    resources :moves
  end

  resources :rounds do
    resources :events
    resources :moves
  end

  resources :game_users do
    resources :rations
    resources :cards
    resources :moves
  end

  resources :actions
  resources :records
  resources :moves
  resources :events
  #resources :cows

  resources :positions
  get 'positions/:id/graph/:depth' => 'positions#graph'
  get 'games/:game_id/positions/:id/graph/:depth' => 'positions#graph'

  get 'login' => 'users#login'
  post 'login' => 'users#login'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

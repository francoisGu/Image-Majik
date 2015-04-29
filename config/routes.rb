Rails.application.routes.draw do
  #resources :versions

  resources :folders, only: [:show, :new, :edit, :create, :update, :destroy] do
    resources :images, only: [:show, :new, :edit, :create, :update, :destroy] do
      resources :versions, only: :show
    end
  end

  devise_for :users, :controllers => { :registrations => "registrations" }

  root to: "pages#home"

  get 'folders' => 'folders#my_folders', as: :my_folders
  get 'folders/:id/empty' => 'folders#empty_trash', as: :empty_trash
  get 'folders/:folder_id/images/:id/delete' => 'images#move_to_trash', as: :delete_folder_image
  get 'folders/:folder_id/images/:id/put_back' => 'images#put_back', as: :put_back_folder_image
  get 'folders/:folder_id/images/:id/share' => 'images#share', as: :share_folder_image
  get 'folders/:folder_id/images/:id/add_to_album' => 'images#add_to_album', as: :add_to_album_folder_image
  get 'folders/:folder_id/images/:id/download' => 'images#download', as: :download_folder_image
  get 'folders/:folder_id/images/:id/add_filter' => 'images#add_filter', as: :add_filter_folder_image
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
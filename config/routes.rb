Rboatree::Application.routes.draw do
  
  root 'home#index'

  get 'validation' => 'validate_data#index'
  get 'validate' => 'validate_data#validate'

  get 'edit' => 'edit#index'
  get 'edit/about' => 'edit#about'
  get 'edit/test' => 'edit#test'
  get 'edit/create-tree-form' => 'edit#create_tree_form'
  post 'edit/create-tree-action' => 'edit#create_tree_action'
  get 'edit/create-workspace-form' => 'edit#create_workspace_form'
  post 'edit/create-workspace-action' => 'edit#create_workspace_action'
  get 'edit/clear-tree-form' => 'edit#clear_tree_form'
  post 'edit/clear-tree-action' => 'edit#clear_tree_action'
  get 'edit/tree/:id' => 'edit#tree'
  get 'edit/trees' => 'edit#list_trees'
  get 'edit/workspace/:id' => 'edit#workspace'
  get 'edit/workspaces' => 'edit#list_workspaces'
  get 'edit/node/:id' => 'edit#node'


  
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

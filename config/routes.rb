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
  get 'edit/trees' => 'edit#list_trees'
  get 'edit/workspaces' => 'edit#list_workspaces'

  get 'tree/:id/delete-tree-form' => 'tree#delete_tree_form'
  post 'tree/:id/delete-tree-action' => 'tree#delete_tree_action'

  get 'tree/:id' => 'tree#tree'
  
  get 'workspace/:id/delete-workspace-form' => 'workspace#delete_workspace_form'
  post 'workspace/:id/delete-workspace-action' => 'workspace#delete_workspace_action'

  get 'workspace/:id' => 'workspace#workspace'

  get 'node/:id/create-node-form' => 'node#create_node_form'
  post 'node/:id/create-node-action' => 'node#create_node_action'

  get 'node/:id/adopt-node-form' => 'node#adopt_node_form'
  post 'node/:id/adopt-node-action' => 'node#adopt_node_action'

  get 'node/:id/checkout-node-form' => 'node#checkout_node_form'
  post 'node/:id/checkout-node-action' => 'node#checkout_node_action'

  get 'node/:id/revert-node-form' => 'node#revert_node_form'
  post 'node/:id/revert-node-action' => 'node#revert_node_action'

  get 'node/:id/finalise-node-form' => 'node#finalise_node_form'
  post 'node/:id/finalise-node-action' => 'node#finalise_node_action'

  get 'node/:id/delete-node-form' => 'node#delete_node_form'
  post 'node/:id/delete-node-action' => 'node#delete_node_action'

  get 'node/:id' => 'node#node'

  get 'versioning/about' => 'versioning#about'
  get 'versioning' => 'versioning#index'

  
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

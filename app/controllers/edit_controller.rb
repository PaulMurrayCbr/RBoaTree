require 'boatree_sql'

class EditController < ApplicationController
  include FlashHelper
  include BoatreeOperations
  include ParamHelper
  
  def index
    setup_sidebar
    flash.discard
  end

  def about
    setup_sidebar
    flash.discard
  end

  def test
    info "Running test operations"
    boatree_test
    redirect_to action: :index
  end

  def clear_tree_form
    setup_sidebar
    flash.discard
  end

  def clear_tree_action
    if not params['confirm']
      warn 'Confirmation?', 'You need to confirm that you want to perform this action'
      return redirect_to action: :clear_tree_form
    end

    boatree_clear

    redirect_to action: :index
  end

  def create_tree_form
    setup_sidebar
    flash.discard
  end

  def create_tree_action
    valid = true
    
    if !params['tree_name'] or params['tree_name'].blank?
      warn 'Specify a tree name'
      valid = false
    end
    
    if !params['tree_uri'] or params['tree_uri'].blank?
      warn 'Specify a uri'
      valid = false
    end
    
    if !valid
    return redirect_to action: :create_tree_form
    end

    tree_id = boatree_create_tree params['tree_name'], params["tree_uri"]

    puts "Tree id is #{tree_id}"

    redirect_to action: :tree, id: tree_id
  end

  def create_workspace_form
    setup_sidebar
    flash.discard
  end

  def create_workspace_action
    valid = true
    
    if !params['workspace_name'] or params['workspace_name'].blank?
      warn 'Specify a workspace name'
      valid = false
    end

    if !valid
      return redirect_to action: :create_workspace_form
    end

    tree_id = boatree_create_workspace params['workspace_name']
    
    redirect_to action: :tree, id: tree_id
  end

  def list_trees
    setup_sidebar
    @list = Tree.tree?
    flash.discard
  end

  def list_workspaces
    setup_sidebar
    @list = Tree.workspace?
    flash.discard
  end

  private

  def setup_sidebar

  end

end

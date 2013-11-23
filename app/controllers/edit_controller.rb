require 'boatree_sql'

class EditController < ApplicationController
  include FlashHelper
  include BoatreeSql
  
  def index
    setup_sidebar
  end

  def about
    setup_sidebar
  end

  def test
    boatree_test
    redirect_to action: :index
  end

  def clear_tree_form
    setup_sidebar
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

    boatree_create_tree params['tree_name'], params["tree_uri"]

    redirect_to action: :index
  end

  def create_workspace_form
    setup_sidebar
  end

  def create_workspace_action
    todo 'todo: create workspace action'
    redirect_to action: :index
  end

  private

  def setup_sidebar

  end

end

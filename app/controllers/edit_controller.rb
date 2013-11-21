require 'boatree_sql'

class EditController < ApplicationController
  include FlashHelper
  include BoatreeSql
  
  def index
    puts 'index action'

    p flash

    setup_sidebar
  end

  def about
    puts 'about action'
    setup_sidebar
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
    if !params['tree_name'] or params['tree_name'].blank?
      warn 'Specify a tree name'
      return redirect_to action: :create_tree_form
    end

    boatree_create_tree params['tree_name']

    redirect_to action: :index
  end

  private

  def setup_sidebar

  end

end

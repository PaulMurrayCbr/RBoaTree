class EditController < ApplicationController
  include FlashHelper
  
  def index
    puts 'index action'
    
    p flash
    
    setup_sidebar
  end

  def about
    puts 'about action'
    setup_sidebar
  end

  def create_tree
    todo 'Create tree action'    
    redirect_to action: :index
  end
  
private

  def setup_sidebar
    
  end

end

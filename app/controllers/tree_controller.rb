require 'boatree_sql'

class TreeController < ApplicationController
  include FlashHelper
  include BoatreeOperations
  include ParamHelper

  def tree
    setup_sidebar
    
    if !params[:id]
      warn "No id specified"
      redirect_to action: :index
      return
    end
 
    id = to_int(params[:id])

    if id.nil?
      warn "\"#{params[:id]}\" is not a number"
      redirect_to action: :index
      return
    end
 
    begin
      @t = Tree.find(id)
    rescue ActiveRecord::RecordNotFound
      warn "Tree #{id} not found"
      redirect_to action: :index
      return
    end 
    
    if @t.end?
      warn "Tree #{id} is the end tree"      
      redirect_to controller: :edit, action: :index
      return
    end
  
    if @t.workspace?
      warn "Tree #{id} is a workspace"      
      redirect_to controller: :workspace, action: :workspace, id: id
      return
    end
  
    flash.discard
  end
  
  private
  
  def setup_sidebar
    
  end
end

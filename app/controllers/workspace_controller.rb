require 'boatree_sql'

class WorkspaceController < ApplicationController
  include FlashHelper
  include BoatreeOperations
  include ParamHelper
  
  def workspace
    setup_sidebar
    
    if !params[:id]
      warn "No id specified"
      redirect_to action: :index
      return
    end
 
    id = to_int(params[:id])

    if id.nil?
      warn "\"#{params[:id]}\" is not a number"
      redirect_to controller: :edit, action: :index
      return
    end
 
    begin
      @ws = Tree.find(id)
    rescue ActiveRecord::RecordNotFound
      warn "Tree #{id} not found"
      redirect_to controller: :edit, action: :index
      return
    end 
    
    if @ws.end?
      warn "Tree #{id} is the end tree"      
      redirect_to controller: :edit, action: :index
      return
    end
  
    if @ws.tree?
      warn "Tree #{id} is a tree"      
      redirect_to controller: :tree, action: :tree, id: id
      return
    end
  
    flash.discard
  end
  
  private
  
  def setup_sidebar
    
  end
end

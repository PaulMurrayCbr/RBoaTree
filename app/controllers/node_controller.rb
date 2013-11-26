require 'boatree_sql'

class NodeController < ApplicationController
  include FlashHelper
  include BoatreeOperations
  include ParamHelper

  def node
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
      @n = TreeNode.find(id)
    rescue ActiveRecord::RecordNotFound
      warn "Node #{id} not found"
      redirect_to action: :index
      return
    end 
    
    todo "node"
    flash.discard
  end

  private
  
  def setup_sidebar
    
  end
end

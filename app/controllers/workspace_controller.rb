require 'boatree_sql'

class WorkspaceController < ApplicationController
  include FlashHelper
  include BoatreeOperations
  include ParamHelper
  
  def workspace
    setup_sidebar
    getws params

    if !@ws
      return redirect_to controller: :edit, action: :list_workspaces
    end
 
    flash.discard
  end
  
  def delete_workspace_form
    getws params
    if !@ws
      return redirect_to controller: :edit, action: :list_workspaces
    end
    
    setup_sidebar
    flash.discard
  end

  def delete_workspace_action
    getws params
    if !@ws
      return redirect_to controller: :edit, action: :list_workspaces
    end
    
    begin
      boatree_delete_workspace @ws.id
      return redirect_to controller: :edit, action: :list_workspaces
    rescue Exception => e
      return redirect_to action: :delete_workspace_form, id: @ws.id
    end
  end

  
  private
  
  def getws(params)
    @ws = getwsparam(params, :id)
  end

  def getwsparam(params, sym)
    id = getintparam(params, sym)
    if id.nil?
      return nil
    end

    begin
      ws = Tree.find(id)
    rescue ActiveRecord::RecordNotFound
      error "Tree #{id} not found"
      return nil
    end
    
    if !ws.workspace?
      error "Tree #{id} is not a workspace"
      return nil
    end
    
    return ws
  end
  
  
  def setup_sidebar
    
  end
end

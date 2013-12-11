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
  
  def delete_tree_form
    gettree params
    if !@t
      return redirect_to controller: :edit, action: :list_trees
    end
    
    setup_sidebar
    flash.discard
  end

  def delete_tree_action
    gettree params
    if !@t
      return redirect_to controller: :edit, action: :list_trees
    end
    
    begin
      boatree_delete_tree @t.id
      return redirect_to controller: :edit, action: :list_trees
    rescue Exception => e
      return redirect_to action: :delete_tree_form, id: @t.id
    end
  end

  private
  
  def gettree(params)
    @t = gettreeparam(params, :id)
  end

  def gettreeparam(params, sym)
    id = getintparam(params, sym)
    if id.nil?
      return nil
    end

    begin
      t = Tree.find(id)
    rescue ActiveRecord::RecordNotFound
      error "Tree #{id} not found"
      return nil
    end
    
    if !t.tree?
      error "Tree #{id} is not a tree"
      return nil
    end
    
    return t
  end

  def setup_sidebar
    
  end
end

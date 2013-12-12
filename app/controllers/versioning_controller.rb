require 'boatree_sql'

class VersioningController < ApplicationController
  include FlashHelper
  include BoatreeOperations
  include ParamHelper
  
  def index
    @state = Array.new
    
    keys.each do |k|
      e = { node_id: k, node: nn(k), replacement_id: vals[k], replacement: nn(vals[k]) }   
      @state << e   
    end
    
    setup_sidebar
    flash.discard
  end

  def about
    setup_sidebar
    flash.discard
  end

  def add_target_action
    node = getintparam(params, :node)
    replacement = getintparam(params, :replacement)
    
    if node && replacement
      keys.delete(node)
      keys << node
      vals[node] = replacement
    end 
    
    redirect_to action: :index
  end

  def remove_target_action
    node = getintparam(params, :id)
    
    if node
      keys.delete(node)
      vals[node] = nil
    end 
    
    redirect_to action: :index
  end
  
  def perform_versioning_action
    begin
      boatree_perform_versioning vals
    rescue
    end

    redirect_to action: :index
  end
  
  def clear_all_action
    keys.clear
    vals.clear
    redirect_to action: :index
  end
  
  private
  
  def setup_sidebar
  end
  
  def keys
    session[:versioning_keys] = Array.new if !session[:versioning_keys]
    session[:versioning_keys]
  end

  def vals
    session[:versioning_vals] = Hash.new if !session[:versioning_vals]
    session[:versioning_vals]
  end
  
  def nn(id) 
    begin
      return TreeNode.find(id)
    rescue
      return nil
    end
  end
end

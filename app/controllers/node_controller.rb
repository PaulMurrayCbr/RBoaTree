require "boatree_sql"

class NodeController < ApplicationController
  include FlashHelper
  include BoatreeOperations
  include ParamHelper
  def node

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
      @n = TreeNode.find(id)
    rescue ActiveRecord::RecordNotFound
      warn "Node #{id} not found"
      redirect_to controller: :edit, action: :index
    return
    end

    if @n.end?
      warn "Node #{id} is the end node"
      redirect_to controller: :edit, action: :index
    return
    end

    p @n

    if @n.root_of
      puts "node #{id} is root of "

      if @n.root_of.workspace?
        puts "#{id} is root of a workspace"
        warn "Node #{id} is the top node of a workspace"
        redirect_to controller: :workspace, action: :workspace, id: @n.root_of.id
      return
      else
        puts "#{id} is root of a tree"
        warn "Node #{id} is the top node of a tree"
        redirect_to controller: :tree, action: :tree, id: @n.root_of.id
      return
      end
    end

    setup_sidebar

    todo "node"
    flash.discard
  end

  private

  def setup_sidebar

  end
end

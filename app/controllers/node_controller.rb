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

    # ok. work out the tree placements.
    # we have a hash of the trees of the supernodes -> a list of -> a hash of { tree_link, placements[] }

    @placements = Hash.new

    @n.supernode_link.each do |l|
      nugget = NodeController::Placement.new(l)

      if !@placements[l.supernode.tree]
        @placements[l.supernode.tree] = Array.new
      end
      @placements[l.supernode.tree] << nugget

      if l.supernode.current?
        todo 'find placements'
      end
    end

    setup_sidebar

    flash.discard
  end

  private

  def setup_sidebar

  end

  class Placement
    def initialize(link)
      @link = link
      @placements = Array.new
    end

    def link
      @link
    end

    def supernode
      @link.supernode
    end

    def placements
      @placements
    end
  end

end

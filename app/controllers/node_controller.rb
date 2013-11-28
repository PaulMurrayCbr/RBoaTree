require "boatree_sql"

class NodeController < ApplicationController
  include FlashHelper
  include BoatreeOperations
  include ParamHelper

  def node
    getnode params
    if !@n 
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
        sql = "SELECT * from get_tree_placements(#{l.supernode.id})"
        @result = ActiveRecord::Base.connection.execute(sql);
        @result.each do |row| 
          nugget.placements << Tree.find(row['tree_id']) 
        end
      end
    end

    setup_sidebar
    flash.discard
  end

  def create_node_form
    getnode params
    if !@n 
      redirect_to controller: :edit, action: :index
      return
    end
    
    setup_sidebar
    flash.discard
  end

  def create_node_action
    getnode params
    if !@n 
      redirect_to controller: :edit, action: :index
      return
    end

    if ! (/[VFT]/ =~ params[:link_type])
      warn 'Link type must be V, F, or T'
      redirect_to action: :create_node_form, id: @n.id
    end

    begin
      boatree_create_draft_node @n.id, params[:node_name], params[:link_type]
    rescue
      return redirect_to action: :create_node_form, id: @n.id
    end

    redirect_to action: :node, id: @n.id
  end

  def adopt_node_form
    @n = getnode params
    if !@n 
      redirect_to controller: edit, action: :index
      return
    end
    
    setup_sidebar
    flash.discard
  end

  def adopt_node_action
    getnode params
    if !@n 
      redirect_to controller: :edit, action: :index
      return
    end
    
    subn = getnodeparam params, :subnode_id
    if !subn
      redirect_to action: :adopt_node_form, id: n.id
    end

    if ! (/[VFT]/ =~ params[:link_type])
      warn 'Link type must be V, F, or T'
      redirect_to action: :adopt_node_form, id: n.id
    end

    begin
      boatree_adopt_node @n.id, subn.id, params[:link_type]
    rescue
      return redirect_to action: :adopt_node_form, id: @n.id
    end

    redirect_to action: :node, id: @n.id
  end

  private

  def setup_sidebar

  end

  def getnode(params)
    @n = getnodeparam(params, :id)
  end

  def getnodeparam(params, sym)
    id = getintparam(params, sym)
    if id.nil?
      return nil
    end

    begin
      n = TreeNode.find(id)
    rescue ActiveRecord::RecordNotFound
      error "Node #{id} not found"
      return nil
    end
    
    return n
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

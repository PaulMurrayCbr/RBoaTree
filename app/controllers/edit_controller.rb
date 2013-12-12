require 'boatree_sql'

class EditController < ApplicationController
  include FlashHelper
  include BoatreeOperations
  include ParamHelper
  
  def index
    setup_sidebar
    flash.discard
  end

  def about
    setup_sidebar
    flash.discard
  end

  def test
    info "Running test operations"
    boatree_test
    redirect_to action: :index
  end

  def clear_tree_form
    setup_sidebar
    flash.discard
  end

  def clear_tree_action
    if not params['confirm']
      warn 'Confirmation?', 'You need to confirm that you want to perform this action'
      return redirect_to action: :clear_tree_form
    end

    begin
      boatree_clear
      
      generate_sample_data
      
    rescue
      return redirect_to action: :clear_tree_form
    end

    redirect_to action: :index
  end

  def create_tree_form
    setup_sidebar
    flash.discard
  end

  def create_tree_action
    valid = true
    
    if !params['tree_name'] or params['tree_name'].blank?
      warn 'Specify a tree name'
      valid = false
    end
    
    if !params['tree_uri'] or params['tree_uri'].blank?
      warn 'Specify a uri'
      valid = false
    end
    
    if !valid
      return redirect_to action: :create_tree_form
    end

    begin
      tree_id = boatree_create_tree params['tree_name'], params["tree_uri"]
    rescue
      return redirect_to action: :create_tree_form
    end

    puts "Tree id is #{tree_id}"

    redirect_to controller: :tree, action: :tree, id: tree_id
  end

  def create_workspace_form
    setup_sidebar
    flash.discard
  end

  def create_workspace_action
    valid = true
    
    if !params['workspace_name'] or params['workspace_name'].blank?
      warn 'Specify a workspace name'
      valid = false
    end

    if !valid
      return redirect_to action: :create_workspace_form
    end

    begin
      workspace_id = boatree_create_workspace params['workspace_name']
    rescue
      return redirect_to action: :create_workspace_form
    end
    
    if !workspace_id
      return redirect_to action: :create_workspace_form
    end

    redirect_to controller: :workspace, action: :workspace, id: workspace_id
  end

  def list_trees
    setup_sidebar
    @list = Tree.tree?
    flash.discard
  end

  def list_workspaces
    setup_sidebar
    @list = Tree.workspace?
    flash.discard
  end

  private

  def setup_sidebar

  end
  
  def generate_sample_data
    tree = Tree.create(name: 'AFD Sample', tree_type: 'T')
    tree.save;
    top = TreeNode.create(name: 'AFD Sample [TOP]', uri: 'http://example.org/tree#AFDTreeSample', tree_id: tree.id)
    top.save;
    tree.node = top;
    tree.save;
    root = TreeNode.create(name: 'AFD Sample [ROOT]', uri: 'http://example.org/node/AFD#Root', tree_id: tree.id)
    root.save
    l = TreeLink.create(super_node_id: top.id, sub_node_id: root.id, link_type: 'T')
    l.save
    
    n1 = makesamplenode(root, 'MONOTREMATA')
    n2 = makesamplenode(n1, 'ORNITHORHYNCHIDAE')
    n3 = makesamplenode(n2, 'Ornithorhynchus')
    n4 = makesamplenode(n3, 'Ornithorhynchus anatinus')
    n2 = makesamplenode(n1, 'TACHYGLOSSIDAE')
    n3 = makesamplenode(n2, 'Tachyglossus')
    n4 = makesamplenode(n3, 'Tachyglossus aculeatus')
    n5 = makesamplenode(n4, 'Tachyglossus aculeatus acanthion')
    n5 = makesamplenode(n4, 'Tachyglossus aculeatus aculeatus')
    n5 = makesamplenode(n4, 'Tachyglossus aculeatus multiaculeatus')
    n5 = makesamplenode(n4, 'Tachyglossus aculeatus setosus')
    
    tree = Tree.create(name: 'APC Sample', tree_type: 'T')
    tree.save;
    top = TreeNode.create(name: 'APC Sample [TOP]', uri: 'http://example.org/tree#APCTreeSample', tree_id: tree.id)
    top.save;
    tree.node = top;
    tree.save;
    root = TreeNode.create(name: 'APC Sample [ROOT]', uri: 'http://example.org/node/APC#Root', tree_id: tree.id)
    root.save
    l = TreeLink.create(super_node_id: top.id, sub_node_id: root.id, link_type: 'T')
    l.save

    n1 = makesamplenode(root, 'Doodia')
    n2 = makesamplenode(n1, 'Doodia aspera')
    n3 = makesamplenode(n2, 'Doodia aspera var. media')
    n2 = makesamplenode(n1, 'Doodia australis')
    n2 = makesamplenode(n1, 'Doodia caudata')
    n2 = makesamplenode(n1, 'Doodia dissecta')
    n2 = makesamplenode(n1, 'Doodia heterophylla')
    n2 = makesamplenode(n1, 'Doodia hindii')
    n2 = makesamplenode(n1, 'Doodia linearis')
    n2 = makesamplenode(n1, 'Doodia maxima')
    n2 = makesamplenode(n1, 'Doodia media')

    n1 = makesamplenode(root, 'Pteridoblechnum')
    n2 = makesamplenode(n1, 'Pteridoblechnum acuminatum')
    n2 = makesamplenode(n1, 'Pteridoblechnum neglectum')

    n1 = makesamplenode(root, 'Stenochlaena')
    n2 = makesamplenode(n1, 'Stenochlaena palustris')
  end

  def makesamplenode(n, name)
    nn = TreeNode.create(name: name, uri: 'temp', tree_id: n.tree.id)
    nn.save
    nn.uri = "http://example.org/node/AFD#{nn.id}" 
    nn.save
    l = TreeLink.create(super_node_id: n.id, sub_node_id: nn.id, link_type: 'V')
    l.save
    return nn
  end

end

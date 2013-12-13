=begin
This class holds the SQL that performs transformations on the boatree data structure.
The idea is that *All* transformations on the data are *only* done here. 
=end

module BoatreeOperations
  include BoatreeSql
  include FlashHelper
  
  # a scrp procedure for executing some code during development
  def boatree_test
    flash_sql << 'Some tests'
    db_call_discard_exception :testproc 
    db_call_discard_exception :testintfunc 
    db_call_discard_exception :testintfuncarg, 6 
    flash_sql << 'These next two should fail'
    db_call_discard_exception :testexcep
    db_call_discard_exception :testexcep
  end

  def boatree_clear
    db_perform do
      n = db_call :boatree_reset
      ok "All data cleared, database reset"
      return to_int(n)
    end
  end

  def boatree_create_tree(tree_name, tree_uri)
    db_perform do
      n = db_call :boatree_create_tree, tree_name, tree_uri
      ok "Tree #{tree_name} created with uri #{tree_uri}"
      return to_int(n)
    end
  end
    
  def boatree_create_workspace(workspace_name)
    db_perform do
      n = db_call :boatree_create_workspace, workspace_name
      ok "Workspace #{workspace_name} created"
      return to_int(n)
    end
  end
    
  def boatree_create_draft_node(supernode_id, node_name, link_type)
    db_perform do
      n = db_call :boatree_create_draft_node, supernode_id, node_name, link_type
      ok "Node link #{n} created under node #{supernode_id}"
      return to_int(n)
    end
  end

  def boatree_adopt_node(supernode_id, subnode_id, link_type)
    db_perform do
      n = db_call :boatree_adopt_node, supernode_id, subnode_id, link_type
      ok "Node link #{n} created under node #{supernode_id}"
      return to_int(n)
    end
  end
  
  def boatree_checkout_node(node_id, workspace_id)
    db_perform do
      n = db_call :boatree_checkout_node, node_id, workspace_id
      ok "Node #{node_id} checked out in workspace #{workspace_id} as #{n}"
      return to_int(n)
    end
  end

  def boatree_delete_node(node_id)
    db_perform do
      n = db_call :boatree_delete_node, node_id
      ok "Node #{node_id} deleted"
      return to_int(n)
    end
  end

  def boatree_delete_workspace(ws_id)
    db_perform do
      n = db_call :boatree_delete_workspace, ws_id
      ok "Workspace #{ws_id} deleted"
      return to_int(n)
    end
  end

  def boatree_delete_tree(tree_id)
    db_perform do
      n = db_call :boatree_delete_tree, tree_id
      ok "Tree #{tree_id} deleted"
      return to_int(n)
    end
  end

  def boatree_finalise_node(node_id)
    db_perform do
      n = db_call :boatree_finalise_node, node_id
      ok "Node #{node_id} finalised"
      return to_int(n)
    end
  end

  def boatree_revert_node(node_id)
    db_perform do
      n = db_call :boatree_revert_node, node_id
      ok "Node #{node_id} reverted"
      return to_int(n)
    end
  end
  
=begin
  Versioning is a bit of a mix, owing to the fact that to pass the stored procedure an array of node id pairs.
  
  To manage this, we create a postgres temporary table and populate it, then invoke the versioning procedure. The interaction
  is limited to three stored procedures: versioning_init, versioning_add, and versioning_exec. 
=end

  def boatree_perform_versioning(node_replacements) 
   db_perform do
    Squirm.use(ActiveRecord::Base.connection.raw_connection) do
      Squirm.procedure(:boatree_versioning_init).call()
      proc_add = Squirm.procedure(:boatree_versioning_add)
      node_replacements.each_pair do | node_id, replacement_node_id |
        proc_add.call(node_id, replacement_node_id)
      end
      Squirm.procedure(:boatree_versioning_exec).call()
    end
   end 
  end
  
  def to_int(s)
    begin
      return Integer(s)
    rescue
      return nil
    end
  end
  
end

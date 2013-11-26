=begin
This class holds the SQL that performs transformations on the boatree data structure.
The idea is that *All* transformations on the data are *only* done here. Ruby activerecord is not used anywhere
to write to the database.
 
=end

module BoatreeOperations
  include BoatreeSql
  include FlashHelper
  
  def boatree_test
    flash_sql << 'Some tests'
    db_call_discard_exception :testproc 
    db_call_discard_exception :testintfunc 
    db_call_discard_exception :testintfuncarg, 6 
    flash_sql << 'these next TWO should'
    db_call_discard_exception :testexcep
    db_call_discard_exception :testexcep
  end

  def boatree_clear
    db_perform do
      db_call :boatree_reset
      ok "All data cleared, database reset"
      return nil
    end
  end

  def boatree_create_tree(tree_name, tree_uri)
    db_perform do
      tree_id = db_call :boatree_create_tree, tree_name, tree_uri
      ok "Tree #{tree_name} created with uri #{tree_uri}"
      return tree_id
    end
  end
    
  def boatree_create_workspace(workspace_name)
    db_perform do
      tree_id = db_call :boatree_create_workspace, workspace_name
      ok "Workspace #{workspace_name} created"
      return tree_id
    end
  end
    
end

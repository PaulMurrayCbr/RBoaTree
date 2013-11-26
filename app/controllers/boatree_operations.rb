module BoatreeOperations
  include BoatreeSql
  include FlashHelper
  
  def boatree_test
    db_perform do
      flash_sql << 'Some tests'
      db_call :testproc 
      db_call :testintfunc 
      db_call :testintfuncarg, 6 
      flash_sql << 'this next one should fail'
      db_call :testexcep
    end
  end

  def boatree_clear
    db_perform do
      db_call :boatree_reset
      ok "All data cleared, database reset"
    end
  end

  def boatree_create_tree(tree_name, tree_uri)
    db_perform do
      tree_id = db_call :boatree_create_tree, tree_name, tree_uri
      ok "Tree #{tree_name} created with uri #{tree_uri}"
    end
  end
    
  def boatree_create_workspace(workspace_name)
    db_perform do
      tree_id = db_call :boatree_create_workspace, workspace_name
      ok "Workspace #{workspace_name} created"
    end
  end
    
end

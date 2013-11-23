module BoatreeOperations
  include BoatreeSql
  
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
    end
  end

  def boatree_create_tree(tree_name, tree_uri)
    db_perform do
      tree_id = db_call :boatree_create_tree, tree_name
      tree_node = db_call :boatree_create_tree_node, tree_id, "#{tree_name} [TOP NODE]"
      root_node = db_call :boatree_create_node, tree_id, "#{tree_name} [ROOT]"
      db_call :boatree_adopt_node_tracking, tree_node, root_node
      db_call :boatree_finalise_node_recursive, root_node
      db_call :boatree_finalise_node_uri, tree_node, tree_uri
    end
  end
    
end

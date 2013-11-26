class Tree < ActiveRecord::Base
  self.table_name = 'tree'
  belongs_to :node, class_name: :TreeNode, foreign_key: :tree_node_id
  
  def self.tree?
    # I would like to express this better. I would like to be using ruby names, not table names
    Tree.joins(:node).where("tree_node.uri is not null").where("tree.id <> 0")
  end
    
  def self.workspace?
    Tree.joins(:node).where("tree_node.uri is null").where("tree.id <> 0")
  end
    
  def tree?
    ! node.uri.nil?
  end  
    
  def workspace?
    node.uri.nil?
  end  
    
  def end?
    id == 0
  end
end

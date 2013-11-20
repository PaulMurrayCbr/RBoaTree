class Tree < ActiveRecord::Base
  self.table_name = 'tree'
  belongs_to :node, class_name: :TreeNode, foreign_key: :root_node_id
  
  def end?
    id == 0
  end
end

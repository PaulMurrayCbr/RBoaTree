class TreeLink < ActiveRecord::Base
  self.table_name = 'tree_link'
  belongs_to :supernode, class_name: :TreeNode, foreign_key: :super_node_id
  belongs_to :subnode, class_name: :TreeNode, foreign_key: :sub_node_id
  
  def fixed?
    link_type == 'F'
  end
  
  def tracking?
    link_type == 'T'
  end
  
  def versioning?
    link_type == 'V'
  end
  
end

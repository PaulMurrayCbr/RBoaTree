class TreeNode < ActiveRecord::Base
  self.table_name = 'tree_node'
  has_one :next, class_name: :TreeNode, foreign_key: :next_node_id
  has_one :prev, class_name: :TreeNode, foreign_key: :prev_node_id

  has_many :next_of, class_name: :TreeNode, foreign_key: :prev_node_id
  has_many :prev_of, class_name: :TreeNode, foreign_key: :next_node_id

  has_many :supernode_link, class_name: :TreeLink, foreign_key: :sub_node_id
  has_many :subnode_link, class_name: :TreeLink, foreign_key: :super_node_id

end

class TreeNode < ActiveRecord::Base
  self.table_name = 'tree_node'
  
  belongs_to :replacement, class_name: :TreeNode, foreign_key: :next_node_id
  belongs_to :copy_of, class_name: :TreeNode, foreign_key: :prev_node_id

  has_many :replacement_of, class_name: :TreeNode, foreign_key: :next_node_id
  has_many :copies, class_name: :TreeNode, foreign_key: :prev_node_id

  has_many :supernode_link, class_name: :TreeLink, foreign_key: :sub_node_id
  has_many :subnode_link, class_name: :TreeLink, foreign_key: :super_node_id

  has_one :root_of, class_name: :Tree, foreign_key: :tree_node_id

  belongs_to :tree, class_name: :Tree, foreign_key: :tree_id

  def end?
    id == 0
  end
  
  def draft?
    ! uri
  end

  def final?
    ! ! uri
  end
  
  def top?
    ! ! root_of
  end
  
  def current?
    ! replacement
  end

  def replaced?
    ! ! replacement
  end
end

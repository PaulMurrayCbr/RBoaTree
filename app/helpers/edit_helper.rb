module EditHelper
  def node_css(node)
    css = 'node'
    if !node
      css << ' node-nil'
    else
      css = 'node'

      if node.published?
        css << ' node-published'
      else
        css << ' node-unpublished'
      end

      if node.draft?
        css << ' node-draft'
      else
        css << ' node-final'
      end

      if node.next
        css << ' node-replaced'
      else
        css << ' node-current'
      end

      # importnat stuff goes at the end, to override

      if node.end?
        css << ' node-end'
      end

      if node.root_of && node.root_of.workspace?
        css << ' node-workspace-top'
      end

      if node.root_of && node.root_of.tree?
        css << ' node-tree-top'
      end

    end
    return css
  end
  
  def tree_css(tree)
    css = 'tree'
    if !tree
      css << ' tree-nil'
    elsif tree.end?
      css << ' tree-end'
    elsif tree.workspace?
      css << ' tree-workspace'
    elsif tree.tree?
      css << ' tree-tree'
    end
  end
  
end

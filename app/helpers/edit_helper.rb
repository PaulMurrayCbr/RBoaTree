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

      if node.replaced?
        css << ' node-replaced'
      else
        css << ' node-current'
      end

      # importnat stuff goes at the end, to override

      if node.end?
        css << ' node-end'
      end

      if node.top? && node.root_of.workspace?
        css << ' node-workspace-top'
      end

      if node.top? && node.root_of.tree?
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
  
  def link_css(link)
    css = 'link'
    if link.nil?
      css << ' link-nil'
    elsif link.versioning?
      css << 'link-versioning'
    elsif link.tracking?
      css << 'link-tracking'
    elsif link.fixed?
      css << 'link-fixed'
    end    
    return css
  end
  
  def link_symbol(link)
    if link.nil?
      return '?'
    elsif link.versioning?
      return '&#x2192;'
    elsif link.tracking?
      return '&#x21AA;'
    elsif link.fixed?
      return '&#x21e5;'
    end    
  end
end

class ValidateDataController < ApplicationController
  include MsgHelper
  include BoatreeSql
  
  def index
    puts __FILE__, __LINE__

  end

  def validate
    puts __FILE__, __LINE__

    @results = Msg.new

    msg = @results.add('self check')
    msg.add 'default'
    msg.ok 'ok'
    msg.info 'info'
    msg.warn 'warn'
    msg.error 'error'
    msg = @results.add('check tables')
    tt(msg, 'Tree exists') { Tree.count }
    tt(msg, 'TreeNode exists') { TreeNode.count }
    tt(msg, 'TreeLink exists') { TreeLink.count }
    msg = @results.add('database integrity checks')
    check msg, :boatree_validate_no_op
    check msg, :boatree_validate_error
    check msg, :boatree_validate_end_node
    msg = @results.add('TO BE REMOVED')
    tt(msg, 'There should be a END tree') { Tree.find(0) }
    tt(msg, 'There should be a END node') { TreeNode.find(0) }
    ttt(msg, 'The node of the end tree should be the end node') { Tree.find(0).node == TreeNode.find(0) }
    ttt(msg, 'End node should have no previous version') { TreeNode.find(0).prev == nil}
    ttt(msg, 'End node should have no next version') { TreeNode.find(0).next == nil}
    ttt(msg, 'End node should have no supernodes') { TreeNode.find(0).supernode_link.empty?}
    ttt(msg, 'End node should have no subnodes') { TreeNode.find(0).subnode_link.empty?}
    ttt(msg, 'End node should not be the prev of any node') { TreeNode.find(0).prev_of.empty?}
  end

  def tt(msg, t, &b)
    begin
      r = b.call
      msg.ok(t, r)
    rescue  Exception => e
      msg.error(t, e)
    end
  end

  def check(msg, test_name)
    begin
      db_raw_call test_name
      msg.ok test_name
    rescue PG::RaiseException => e
      msg.warn test_name, e.message.strip
    rescue Exception => e
      msg.error test_name, e.to_s
    end
  end

  def ttt(msg, t, &b)
    begin
      if b.call
        msg.ok(t)
      else
        msg.warn(t)
      end
    rescue  Exception => e
      msg.error(t, e)
    end
  end

end

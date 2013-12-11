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
    
    
    msg = @results.add('boatree_validate_sample_message')
    
    Squirm.use(ActiveRecord::Base.connection.raw_connection) do
      begin
        results = ActiveRecord::Base.connection.execute('discard temp')
        db_raw_call 'boatree_validate_create_results_table'
        db_raw_call 'boatree_validate_sample_message'
        results = ActiveRecord::Base.connection.execute('select * from validation_results order by id')
        display_validation_results msg, results.to_enum
      rescue PG::RaiseException => e
        msg.error e.message
      rescue Exception => e
        msg.error e.to_s
      end
    end
    
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
    ttt(msg, 'End node should have no previous version') { TreeNode.find(0).copy_of == nil}
    ttt(msg, 'End node should have no next version') { TreeNode.find(0).replacement == nil}
    ttt(msg, 'End node should have no supernodes') { TreeNode.find(0).supernode_link.empty?}
    ttt(msg, 'End node should have no subnodes') { TreeNode.find(0).subnode_link.empty?}
    ttt(msg, 'End node should not be the prev of any node') { TreeNode.find(0).copies.empty?}
  end

  def display_validation_results(msg, results) 
      while true do
        begin
          r = results.next
          if r['end_sublist'] == 't'
            return
          end
          m = msg.add r['msg']
          
          if r['status'] == 'k'
            m.ok!
          elsif r['status'] == 'i'
            m.info!
          elsif r['status'] == 'w'
            m.warn!
          elsif r['status'] == 'e'
            m.error!
          end
          
          if r['start_sublist'] == 't'
            display_validation_results m, results
          end
        rescue StopIteration
          return
        end    
      end
      msg.info results.next
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

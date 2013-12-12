class ValidateDataController < ApplicationController
  include MsgHelper
  include BoatreeSql
  
  def index
    puts __FILE__, __LINE__

  end

  def validate
    puts __FILE__, __LINE__

    @results = Msg.new

    Squirm.use(ActiveRecord::Base.connection.raw_connection) do
      begin
        db_raw_call 'boatree_validate_create_results_table'
        db_raw_call 'boatree_validate_all'
        results = ActiveRecord::Base.connection.execute('select * from validation_results order by id')
        display_validation_results @results, results.to_enum
      rescue PG::RaiseException => e
        msg.error e.message
      rescue Exception => e
        msg.error e.to_s
      end
    end
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

end

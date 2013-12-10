=begin
 This class holds methods for running stored procedures in postgres, with helpers to build state for our
 views. Its methods throw up flash messages and append to the flash[:sql] log.
=end

module BoatreeSql
  include FlashHelper
  class SqlResult
    def initialize(proc, binds)
      @proc = proc.to_sym
      @ms = 0
      @binds = binds
      @result = nil
      @exception = nil
      @ok = false
    end

    def ok!
      @ok = true
    end

    def fail!
      @ok = false
    end

    def ok?
      @ok
    end

    def fail?
      ! @ok
    end

    def ms=(ms)
      @ms = ms
    end

    def ms
      @ms
    end

    def result=(result)
      @result = result
    end

    def result
      @result
    end

    def exception=(exception)
      @exception = exception
    end

    def exception
      @exception
    end

    def proc
      @proc
    end

    def binds
      @binds
    end
  end

  # perform a block inside a transaction

  def db_perform(&block)
    t = Time.now
    begin
      ActiveRecord::Base.transaction do
        return block.call
      end
    rescue Exception => e
      exception e
      raise e
    ensure
      info 'Time:', "#{((Time.now - t) * 1000).to_i}ms"
    end
  end

  # perform a block inside a transaction, return nil if there is an exception

  def db_perform_discard_exception(&block)
    begin
      return db_perform &block
    rescue
      return nil
    end
  end

  # call an sql stored procedure, adding a result to flash_sql for the sql_results partial

  def db_call(proc, *args)
    r = SqlResult.new(proc, args)
    flash_sql << r
    t = Time.now
    Squirm.use(ActiveRecord::Base.connection.raw_connection) do
      begin
        r.result = db_raw_call proc, *args
        r.ok!
      rescue PG::RaiseException => e
        r.result = e.message
        r.fail!
      rescue Exception => e
        r.result = e.to_s
        r.fail!
      end
    end

    r.ms = ((Time.now - t) * 1000).to_i
    
puts "#{proc}(#{args}) => #{r.result}"    
    
    if r.ok?
      return r.result
    else
      raise "#{proc}: #{r.result}"
    end
  end
  
  # call an sql stored procedure, adding a result to flash_sql for the sql_results partial
  # if an exception occurs, ignore it and return nil
  def db_call_discard_exception(proc, *args)
    begin
      return db_call(proc, *args)
    rescue
      return nil
    end
  end

  # call an sql stored procedure, no wrapping or exception handling

  def db_raw_call(proc, *args)
    Squirm.use(ActiveRecord::Base.connection.raw_connection) do
      sql = Squirm.procedure(proc)
      return sql.call(*args)
    end
  end

  # get or create flash[:sql] for the sql_results partial

  def flash_sql
    flash[:sql] = Array.new unless flash[:sql]
    flash[:sql]
  end
end
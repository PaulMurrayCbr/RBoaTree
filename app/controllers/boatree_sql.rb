=begin
This class holds the SQL that performs transformations on the boatree data structure.
The idea is that *All* transformations on the data are *only* done here. Ruby activerecord is not used anywhere
to write to the database.
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

  # clear the database, completely resetting it to an empty state

  def db_perform(&block)
    t = Time.now
    begin
      ActiveRecord::Base.transaction do
        return block.call
      end
    rescue Exception => e
      error e.to_s
      return nil
    ensure
      info 'Time:', "#{((Time.now - t) * 1000).to_i}ms"
    end
  end

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
    if r.ok?
      return r.result
    else
      raise r.result
    end
  end

  def db_raw_call(proc, *args)
    Squirm.use(ActiveRecord::Base.connection.raw_connection) do
      sql = Squirm.procedure(proc)
      return sql.call(*args)
    end
  end

  def flash_sql
    flash[:sql] = Array.new unless flash[:sql]
    flash[:sql]
  end
end
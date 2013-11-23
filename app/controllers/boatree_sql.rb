=begin
This class holds the SQL that performs transformations on the boatree data structure.
The idea is that *All* transformations on the data are *only* done here. Ruby activerecord is not used anywhere
to write to the database.
=end

module BoatreeSql
  include FlashHelper
  class SqlResult
    def initialize(sql, binds)
      @sql = sql
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

    def sql
      @sql
    end

    def binds
      @binds
    end
  end

  def boatree_test
    info "boatree test executed at #{Time::now}"
    begin
      flash_sql << 'Some tests'
      ok call("testproc")
      ok call("testintfunc")
      ok call("testintfuncarg", 6)
      flash_sql << 'this next one should fail'
      ok call("testexcep")
    rescue Exception => e
      error e.to_s
    end
  end

  # clear the database, completely resetting it to an empty state
  def boatree_clear
    call("boatree_reset")
  end

  def boatree_create_tree(tree_name, tree_uri)
    t = Time.now
    msg = info 'Actions'
    ActiveRecord::Base.transaction do
      tree_id = ins('insert into tree(name) values ( $1 )', tree_name)
      msg.info "Created tree #{tree_id}, named \"#{tree_name}\""

      tree_node = ins('insert into tree_node(name, tree_id, uri) values ($1, $2, $3)', tree_name, tree_id, tree_uri)
      msg.info "Created and finalised tree node #{tree_node}"

      root_node = ins('insert into tree_node(name, tree_id) values ($1, $2)', "#{tree_name} ROOT", tree_id)
      upd('update tree_node set uri=\'http://example.org/node#\'||id where id=$1', root_node)
      msg.info "Created and finalised initial tree root node #{root_node}"

      ins('insert into tree_link(super_node_id, sub_node_id, link_type) values ($1, $2, $3)', tree_node, root_node, 'T')
      msg.info "Linked tree node to root node with a TRACKING link"

    end
    ok "Action sucessful. #{((Time.now - t) * 1000).to_i}ms"
  end

  def call(proc, *args)
    r = SqlResult.new(proc, args)
    flash_sql << r
    t = Time.now
    Squirm.use(ActiveRecord::Base.connection.raw_connection) do
      sql = Squirm.procedure(proc)
      begin
        r.result = sql.call(*args)
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

  def del(sql, *binds)
    r = SqlResult.new(sql, binds)
    flash_sql << r
    t = Time.now
    r.result = ActiveRecord::Base.connection.delete(sql, 'SQL', binds.map { |b| [nil, b]})
    r.ms = ((Time.now - t) * 1000).to_i
    return r.result
  end

  def upd(sql, *binds)
    r = SqlResult.new(sql, binds)
    flash_sql << r
    t = Time.now
    r.result = ActiveRecord::Base.connection.update(sql, 'SQL', binds.map { |b| [nil, b]})
    r.ms = ((Time.now - t) * 1000).to_i
    return r.result
  end

  def ins(sql, *binds)
    r = SqlResult.new(sql, binds)
    flash_sql << r
    t = Time.now
    r.result = ActiveRecord::Base.connection.insert(sql, 'SQL', nil, nil, nil, binds.map { |b| [nil, b]})
    r.ms = ((Time.now - t) * 1000).to_i
    return r.result
  end

  def flash_sql
    flash[:sql] = Array.new unless flash[:sql]
    flash[:sql]
  end
end

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

    def sql
      @sql
    end

    def binds
      @binds
    end
  end
  
  def boatree_test
    info "boatree test executed at #{Time::now}"
    Squirm.use(ActiveRecord::Base.connection.raw_connection) do
       sql = Squirm.procedure("testintfunc")
       result = sql.call()
       ok result.inspect
       
       sql = Squirm.procedure("testproc")
       result = sql.call()
       ok result.inspect
       
       sql = Squirm.procedure("testintfuncarg")
       result = sql.call(6)
       ok result.inspect
    end
  end

  # clear the database, completely resetting it to an empty state
  def boatree_clear
    t = Time.now
    msg = info 'Actions'
    ActiveRecord::Base.transaction do
      del 'delete from tree_link'
      msg.info 'deleted all tree links'
      
      upd 'update tree set root_node_id = null'
      del 'delete from tree_node'
      msg.info 'deleted all tree nodes'
      
      del 'delete from tree'
      msg.info 'deleted all trees'
      
      ins 'insert into tree(id, name) values (0, \'[END]\')'
      ins 'insert into tree_node(id, name, tree_id, uri)
values (0, \'[END]\', 0, \'http://biodiversitry.org.au/boatree/structure#END\')'
      upd 'update tree set root_node_id = 0 where id = 0'
      msg.info 'rebuilt the END tree and END node, id set to zero'
    end
    ok "Action sucessful. #{((Time.now - t) * 1000).to_i}ms"
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
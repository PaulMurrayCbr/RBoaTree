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

  # clear the database, completely resetting it to an empty state
  def boatree_clear
    t = Time.now
    ActiveRecord::Base.transaction do
      del 'delete from tree_link'
      upd 'update tree set root_node_id = null'
      del 'delete from tree_node'
      del 'delete from tree'
      ins 'insert into tree(id, name) values (0, \'[END]\')'
      ins 'insert into tree_node(id, name, tree_id, uri)
values (0, \'[END]\', 0, \'http://biodiversitry.org.au/boatree/structure#END\')'
      upd 'update tree set root_node_id = 0 where id = 0'
    end
    ok "Action sucessful. #{((Time.now - t) * 1000).to_i}ms"
  end 
  
  def boatree_create_tree(tree_name)
    t = Time.now
    ActiveRecord::Base.transaction do
      ins('insert into tree(name) values ( :tree_name )', {tree_name: tree_name})
    end
    ok "Action sucessful. #{((Time.now - t) * 1000).to_i}ms"
  end

  def del(sql, binds = nil)
    r = SqlResult.new(sql, binds)
    flash_sql << r
    t = Time.now
    r.result = ActiveRecord::Base.connection.exec_delete(sql, 'SQL', binds)      
    r.ms = ((Time.now - t) * 1000).to_i
  end
  
  def upd(sql, binds = nil)
    r = SqlResult.new(sql, binds)
    flash_sql << r
    t = Time.now
    r.result = ActiveRecord::Base.connection.exec_update(sql, 'SQL', binds)      
    r.ms = ((Time.now - t) * 1000).to_i
  end
  
  def ins(sql, binds = nil)
    r = SqlResult.new(sql, binds)
    flash_sql << r
    t = Time.now
    r.result = ActiveRecord::Base.connection.exec_insert(sql, 'SQL', binds)      
    r.ms = ((Time.now - t) * 1000).to_i
    return result
  end

  def flash_sql
    flash[:sql] = Array.new unless flash[:sql]
    flash[:sql]
  end
end
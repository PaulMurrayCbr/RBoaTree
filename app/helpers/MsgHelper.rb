=begin
Our test results are nested hashes. This module has some common operations
=end
class Msg < Array
  def initialize()
    @msg = nil
    @item = Hash.new
    @cssclass = 'default'
  end

  def initialize(msg)
    @msg = msg
    @item = Hash.new
    @cssclass = 'default'
  end

  def cssclass
    @cssclass
  end

  def msg
    @msg
  end

  def [](k)
    k = k.to_sym
    if not @item[k]
      @item[k] = Msg.new
    self << @item[k]
    end
    @item[k]
  end

  def ok
    @cssclass = 'success'
    self
  end

  def ok(msg)
    self << MsgHelper::Msg.new(msg).ok
  end

  def ok(k, msg)
    self[k].ok msg
  end

  def info
    @cssclass = 'info'
    self
  end

  def info(msg)
    self << MsgHelper::Msg.new(msg).info
  end

  def info(k, msg)
    self[k].info msg
  end

  def warn
    @cssclass = 'warn'
    self
  end

  def warn(msg)
    self << MsgHelper::Msg.new(msg).warn
  end

  def warn(k, msg)
    self[k].warn msg
  end

  def error
    @cssclass = 'important'
    self
  end

  def error(msg)
    self << MsgHelper::Msg.new(msg).error
  end

  def error(k, msg)
    self[k].error msg
  end
end
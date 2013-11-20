module MsgHelper
  class Msg < Array
    def initialize(msg = nil, extra = nil)
      @msg = msg
      @extra = extra
      @item = Hash.new
      @cssclass = 'default'
    end

    def cssclass
      @cssclass
    end

    def msg
      @msg
    end

    def extra
      @extra
    end

    def ok!
      @cssclass='success'
      self
    end

    def ok?
      @cssclass == 'success'
    end

    def info!
      @cssclass='info'
      self
    end

    def warn!
      @cssclass='warning'
      self
    end

    def error!
      @cssclass='important'
      self
    end

    def ok(msg = nil, extra = nil)
      if msg.class != Msg
        msg = Msg.new(msg, extra).ok!
      end
      self << msg
      msg
    end

    def info(msg = nil, extra = nil)
      if msg.class != Msg
        msg = Msg.new(msg, extra).info!
      end
      self << msg
      msg
    end

    def warn(msg = nil, extra = nil)
      if msg.class != Msg
        msg = Msg.new(msg, extra).warn!
      end
      self << msg
      msg
    end

    def error(msg = nil, extra = nil)
      if msg.class != Msg
        msg = Msg.new(msg, extra).error!
      end
      self << msg
      msg
    end

    def add(msg = nil, extra = nil)
      if msg.class != Msg
        msg = Msg.new(msg, extra)
      end
      self << msg
      msg
    end
  end

end
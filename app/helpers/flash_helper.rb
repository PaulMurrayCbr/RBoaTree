require 'msg_helper'
module FlashHelper
  include MsgHelper
  
  def todo(msg) 
    mm.info 'TODO', msg
  end  

  def ok(msg, extra=nil) 
    mm.ok msg, extra
  end  

  def info(msg, extra=nil) 
    mm.info msg, extra
  end  

  def warn(msg, extra=nil) 
    mm.warn msg, extra
  end  

  def error(msg, extra=nil) 
    mm.error msg, extra
  end  
   
  def exception(e) 
    mm.error 'Error!', e.to_s
  end  
   
  private
  
  def mm
    flash[:message] = Msg.new unless flash[:message]
    flash[:message]
  end
end
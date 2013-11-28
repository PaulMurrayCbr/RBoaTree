module ParamHelper
  # I'm taken aback that ruby doesn't have a kernel method to do this
  def to_int(s)
    begin
      return Integer(s)
    rescue
      return nil
    end
  end
  
  def getintparam(params, sym)
    if !params[sym]
      warn "No #{sym} specified"
      return nil
    end

    id = to_int(params[sym])

    if id.nil?
      warn "\"#{params[sym]}\" is not a number"
      return nil
    end
    
    return id
    
  end
end
module ParamHelper
  # I'm taken aback that ruby doesn't have a kernel method to do this
  def to_int(s)
    begin
      return Integer(s)
    rescue
      return nil
    end
  end
  
  
end
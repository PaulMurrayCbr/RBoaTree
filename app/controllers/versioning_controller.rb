require 'boatree_sql'

class VersioningController < ApplicationController
  include FlashHelper
  include BoatreeOperations
  include ParamHelper
  
  def index
    setup_sidebar
    flash.discard
  end

  def about
    setup_sidebar
    flash.discard
  end

  private
  
  def setup_sidebar
  end
end

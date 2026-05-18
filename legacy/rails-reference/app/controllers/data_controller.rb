class DataController < ApplicationController
  def index
  	
  end

  def petitions
  	
  end

  def petitions_count
    render partial:'data/petitions/petitions_count'
  end

  def petitions_support_spread
    render partial:'data/petitions/petitions_support_spread'
  end

end

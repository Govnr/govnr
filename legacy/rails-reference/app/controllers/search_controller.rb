class SearchController < ApplicationController

  def search
  	@query = params[:q];
  	@search = Sunspot.search [Petition, User] do
        keywords @query
        paginate(:page => params[:page], :per_page => 20)
    end

    @sunspot_search = Sunspot.search Petition, User do |query| 
	  query.keywords @query
	  query.paginate(:page => params[:page], :per_page => 20)
	end

  end

end

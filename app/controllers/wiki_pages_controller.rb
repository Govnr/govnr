class WikiPagesController < ApplicationController
  acts_as_wiki_pages_controller

	def show_allowed?
	  true # Show page to all users
	end

	def history_allowed?
	  true # Show history to all users
	end

	def edit_allowed?
	  current_user ? true : false # Allow editing only to logged users
	end

	def destroy_allowed?
	    @page.path != '' && admin_user_signed_in? 
	    # Allow editing only to admins, and not to root page
	end

	def not_allowed
	  redirect_to login_path # Redirect to login_url when user tries something what not allowed
	end

end

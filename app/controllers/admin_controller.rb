class AdminController < ApplicationController
before_filter :authenticate_admin!
  def configuration
  end

  private 
	def authenticate_admin!
		unless (current_user.has_role?(:admin))
			flash[:error] = "You don't have permission to access that page. Please <a href='*'>contact the support team</a> if you think this is an error."
			redirect_to root_path
		end
	end
  			
end

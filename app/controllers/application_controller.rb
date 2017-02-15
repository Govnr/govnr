class ApplicationController < ActionController::Base

include PublicActivity::StoreController
include TimeFormatting

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	# rescue_from ActiveRecord::RecordNotFound do
	#   flash[:warning] = 'Resource not found.'
	#   redirect_back_or root_path
	# end

	def redirect_back_or(path)
	  redirect_to request.referer || path
	end

	def current_group
		if current_user && current_user.current_group_id
			Group.friendly.find(current_user.current_group_id)
		end
	end

	# def self.convert_to_seconds(value,unit)
	# 	case unit.downcase
	# 	when 'seconds'
	# 		num = 1
	# 	when 'minutes'
	# 		num = 60
	# 	when 'hours'
	# 		num = 3600
	# 	when 'days'
	# 		num = 86400
	# 	end
	# 	return value * num
	# end

end

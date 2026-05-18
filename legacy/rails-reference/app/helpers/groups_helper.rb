module GroupsHelper
	def group_avatar(group, options = {})
		if group.group_setting.nil?
			users_icon
		else
		    if group.group_setting.logo.nil?
		      image_tag group.group_setting.avatar_url, options
		    else
		      image_tag group.group_setting.logo.thumb('150x150#').url, options
		    end
		end
	end
end

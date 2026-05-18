module ApplicationHelper
	def gravatar_for(user, size = 30, title = user.name)
	  image_tag gravatar_image_url(user.email, size: size), title: title, class: 'img-rounded'
	end

	def get_recent_conversations
		@conversations = current_user.mailbox.inbox.limit(5) if current_user.present?
	end

	def get_recent_activity
		@activities = PublicActivity::Activity.where("owner_id IN (:following_ids) OR owner_id = :user_id",
	                following_ids: current_user.following_ids, user_id: current_user.id).order("created_at desc").limit(5)
	end

	def activity_week(group_id)
		group_slug = to_slug(group_id)
		activities = PublicActivity::Activity.where('group_id = ?', Group.friendly.find(group_id).id).where('created_at >= ?', 1.week.ago ).order("created_at desc")
		@all_activities = []
	    @followed_activities = []
	    @comment_activities = []
	    @petition_activities = []
	    @motion_activities = []
	    @draft_activities = []
	    activities.each do |activity|
	      @all_activities << activity
          @followed_activities << activity if (current_user.following_ids.include? activity.owner_id) || (activity.owner_id == current_user.id)
          @comment_activities << activity if activity.trackable_type == 'Comment'
          @petition_activities << activity if activity.trackable_type == 'Petition'
          @motion_activities << activity if activity.trackable_type == 'Motion'
          @draft_activities << activity if activity.trackable_type == 'Draft'
	    end
	    col1 = '<div class="col-xs-4 col-sm-2 activity-week-col"><div class="panel panel-grey"><div class=""><div class="activity-week-header">'
	    col2 = '</div><div class="activity-week-value">'
	    col3 = '</div></div></div></div>'
	    html = '<div class="row-centered">'
	    # html = activity_week_col('fa-newspaper-o','All',@all_activities.size)
	    html << link_to(group_path(id:group_slug, feed:'all')) do 
	    			(col1 + '<i class="fa fa-newspaper-o fa-fw"></i> All' + 
	    			col2 + @all_activities.size.to_s + col3).html_safe
	    		end
	    html << link_to(group_path(id:group_slug, feed:'followed')) do 
	    			(col1 + '<i class="fa fa-users fa-fw"></i> Followed' + 
	    			col2 + @followed_activities.size.to_s + col3).html_safe
	    		end
	    html << link_to(group_path(id:group_slug, feed:'comment')) do 
	    			(col1 + '<i class="fa fa-comments fa-fw"></i> Comment' + 
	    			col2 + @comment_activities.size.to_s + col3).html_safe
	    		end
	    html << link_to(group_path(id:group_slug, feed:'petition')) do 
	    			(col1 + '<i class="fa fa-bullhorn fa-fw"></i> Petition' + 
	    			col2 + @petition_activities.size.to_s + col3).html_safe
	    		end
		html << link_to(group_path(id:group_slug, feed:'motion')) do 
	    			(col1 + '<i class="fa fa-balance-scale fa-fw"></i> Motion' + 
	    			col2 + @motion_activities.size.to_s + col3).html_safe
	    		end
		html << link_to(group_path(id:group_slug, feed:'motion')) do 
	    			(col1 + '<i class="fa fa-file-text-o fa-fw"></i> Draft' + 
	    			col2 + @draft_activities.size.to_s + col3).html_safe
	    		end
	    # html << '<div class="col-xs-4 activity-week-col"><div class="activity-week-header">Followed</div><div class="activity-week-value">' + @followed_activities.size.to_s + '</div></div>'
	    # html << '<div class="col-xs-4 activity-week-col"><div class="activity-week-header">Comment</div><div class="activity-week-value">' + @comment_activities.size.to_s + '</div></div>'
	    # html << '</div><div class="col-sm-6"><div class="col-xs-4 activity-week-col"><div class="activity-week-header">Petition</div><div class="activity-week-value">' + @petition_activities.size.to_s + '</div></div>'
	    # html << '<div class="col-xs-4 activity-week-col"><div class="activity-week-header">Motion</div><div class="activity-week-value">' + @motion_activities.size.to_s + '</div></div>'
	    # html << '<div class="col-xs-4 activity-week-col"><div class="activity-week-header">Draft</div><div class="activity-week-value">' + @draft_activities.size.to_s + '</div></div>'
	    html << '</div>'
	    return html.html_safe
	end

	def activity_week_col(icon,label,value)
		s = '<div class="col-xs-4 activity-week-col">
			<div class="activity-week-header">
			<i class="fa '
		s << icon + ' fa-fw"></i>'
	    s << label +'</div>
	    	<div class="activity-week-value">'
	    s << value.to_s + '</div></div>'
	    return s
	end

	def to_slug(group_id)
		return Group.friendly.find(group_id).slug
	end

	def current_group
		if current_user && current_user.current_group_id
		  return Group.find(current_user.current_group_id)
		end
	end

	# def get_user_groups
	# 	@user_groups = current_user.groups
	# end

	def admin_icon
       fa_stacked_icon "cogs", base: "square-o"
	end

	def dashboard_icon
       fa_icon "bell-o"
	end

	def users_icon
       fa_icon "users"
	end

	def user_icon
       if (current_user)
			user_avatar(current_user, class: 'img-avatar img-circle', style: 'width:28px;height:28px;')
	   else
       		fa_icon "user"
	   end
	end

	def petition_icon
		fa_icon "bullhorn"
	end

	def motion_icon
		fa_icon "balance-scale"
	end

	def draft_icon
		fa_icon "file-text-o"
	end

	def statute_icon
		fa_icon "university"
	end

	# def message_icon
 #       fa_icon "envelope"
	# end

	# def activity_icon
 #       fa_icon "clock-o"
	# end

end

class DashboardController < ApplicationController
before_filter :authenticate_user!, except: :public

caches_action :index

	def index
		unless (current_user.present?)
			authenticate_user!
		end
		@activities = PublicActivity::Activity.all
		if (params[:start_time].present? && params[:end_time].present?)
		  @activities = PublicActivity::Activity.where(:created_at => params[start_time]..params[end_time])
		end
		  @followed_activities = @activities.where("owner_id IN (:following_ids) OR owner_id = :user_id",
                    following_ids: current_user.following_ids, user_id: current_user.id)
		  @comment_activities = @followed_activities.where("trackable_type = 'Comment'")
		  @petition_activities = @followed_activities.where("trackable_type = 'Petition'")
		case params[:feed]
		when'all'
			@feed = 'All'
		when'comments'
			@activities = @comment_activities
			@feed = 'Comment'
		when'petitions'
			@activities = @petition_activities
			@feed = 'Petition'
		else
			@feed = 'Followed'
			@activities = @followed_activities
			
		end
		respond_to do |format|
	      format.html { }
	      format.js { }
    	end
	end

	def public

	end
end

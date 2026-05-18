class DashboardController < ApplicationController
before_filter :authenticate_user!, except: :public
before_filter :set_group, except: :public
caches_action :activity

	def index
		unless (current_user.present?)
			authenticate_user!
		end
		@groups = current_user.groups.order('last_active desc')
	end

	def activity
		unless (current_user.present?)
			authenticate_user!
		end
		@activities = Kaminari.paginate_array(get_activities).page(params[:page]).per(20)
		respond_to do |format|
	      format.html { }
	      format.js { }
    	end
	end

	def get_activities
    @all_activities = []
    @followed_activities = []
    @comment_activities = []
    @petition_activities = []
    @motion_activities = []
    @draft_activities = []

    if params[:created_before].present?
      # @dash_params =  params.require(:dashboard).permit(:created_since)
      # @activities = PublicActivity::Activity.where('created_at <= ?', @dash_params[:created_since].to_time(:default) ).order("created_at desc")
      @activities = PublicActivity::Activity.where('created_at <= ?', params[:created_before].to_time(:default) ).order("created_at desc")
     
    else
      @activities = PublicActivity::Activity.order("created_at desc")
    end
    if params[:created_after].present?
      # @dash_params =  params.require(:dashboard).permit(:created_since)
      # @activities = PublicActivity::Activity.where('created_at <= ?', @dash_params[:created_since].to_time(:default) ).order("created_at desc")
      @activities = @activities.where('created_at >= ?', params[:created_after].to_time(:default) ).order("created_at desc")
    end

      @activities.each do |activity|
        if params[:containing].present?
          if (defined? activity.trackable.commentable)
            contained = (
            activity.trackable.commentable.name.include?(params[:containing]) ||
            activity.owner.name.include?(params[:containing])
            )
          else
          contained = (
            activity.trackable.name.include?(params[:containing]) ||
            activity.owner.name.include?(params[:containing])
            )
          end
        else
          contained = true
        end
        if contained
          @all_activities << activity
          @followed_activities << activity if (current_user.following_ids.include? activity.owner_id) || (activity.owner_id == current_user.id)
          @comment_activities << activity if activity.trackable_type == 'Comment'
          @petition_activities << activity if activity.trackable_type == 'Petition'
          @motion_activities << activity if activity.trackable_type == 'Motion'
          @draft_activities << activity if activity.trackable_type == 'Draft'
        end
      end
    if params[:feed].present?
      case params[:feed]
      when'all'
        @feed = 'All'
        @activities = @all_activities
      when'comment'
        @activities = @comment_activities
        @feed = 'Comment'
      when'petition'
        @activities = @petition_activities
        @feed = 'Petition'
      when'motion'
        @activities = @motion_activities
        @feed = 'Motion'
      when'draft'
        @activities = @draft_activities
        @feed = 'Draft'
      when'followed'
        @activities = @followed_activities
        @feed = 'Followed'
      else
        @feed = 'All'
        @activities = @all_activities  
      end
    end
    return @activities
  end

	def public

	end

private
	def set_group
		@group = current_group
	end

end

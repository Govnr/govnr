class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_group, only: [:show, :edit, :update, :destroy, :root, :settings]
  before_action :authenticate_admin, only: [:settings]

  def root
    # if @group.present?
    #   redirect_to action: 'show'
    # else
    #   redirect_to action: 'find'
    # end
    unless (current_user.present?)
      authenticate_user!
    end
  end

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  def find
    @filterrific = initialize_filterrific(
      Group,
      params[:filterrific]
    ) or return
    @groups = Kaminari.paginate_array(@filterrific.find.where('private = false')).page(params[:page]).per(20)
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    unless (current_user.present?)
      authenticate_user!
    end
    @activities = Kaminari.paginate_array(get_activities).page(params[:page]).per(20)
    respond_to do |format|
        format.html { }
        format.js { }
      end
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  def join
    if params[:group_id].present?
      @group = Group.friendly.find(params[:group_id])
      @group.users << current_user
      flash[:notice] = "You joined the group #{@group.name}"
      current_user.save
      redirect_to group_path(@group)
    else
      redirect_back_or '/'
    end
  end

  def assign_role
    @membership = GroupMembership.where('group_id =?',group_membership_params[:group_id])
                  .where('user_id =?',group_membership_params[:user_id]).first
    if @membership.present?
      if ((@membership.user == current_user) && (@membership.has_role?(:admin)) && (!group_membership_params[:roles].include?('admin')))
          flash[:warning] = "You can't remove your own admin role."
          redirect_to group_users_path(:group_id => @membership.group.slug) and return
      end
      @membership.roles = group_membership_params[:roles]
      if @membership.save
        flash[:notice] = "Group membership roles for #{@membership.user.name} have been changed."
      respond_to do |format|
          format.html { redirect_to group_users_path(:group_id => @membership.group.slug) }
          format.js { redirect_to group_users_path(:group_id => @membership.group.slug) }
        end
      else
        flash[:warning] = "Error assigning group membership role."
      end
    end
    
  end

  def set_active
    if params[:group_id].present?
      @group = Group.friendly.find(params[:group_id])
      @group_membership = @group.group_memberships.where('user_id = ?',current_user.id).first
      @group_membership.last_active = DateTime.now
      @group_membership.save
      current_user.current_group_id =  @group.id
      current_user.save
      redirect_to group_path(params[:group_id])
    else
      redirect_back_or '/'
    end
  end

  # def activity
  #   unless (current_user.present?)
  #     authenticate_user!
  #   end
  #   @activities = Kaminari.paginate_array(get_activities).page(params[:page]).per(20)
  #   respond_to do |format|
  #       format.html { }
  #       format.js { }
  #     end
  # end

  def settings
    @group = Group.friendly.find(params[:id])
    @settings = @group.group_setting
    if @settings.nil?
      @group.build_group_setting
      @settings = @group.group_setting
    end
    @settings.set_defaults
  end

  def update_settings
    @group = Group.find(settings_params[:group_id])
    @settings = @group.group_setting
    if @settings.nil?
      @group.build_group_setting
      @settings = @group.group_setting
    end
    @settings.update(settings_params)
    if @settings.save
      flash[:notice] = "Group settings have been updated."
    respond_to do |format|
        format.html { redirect_to settings_group_path(id:@group.slug) }
        format.js { redirect_to settings_group_path(id:@group.slug) }
      end
    else
      flash[:warning] = "Error updating group settings."
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
      @activities = PublicActivity::Activity.where('group_id = ?', Group.friendly.find(params[:id]).id).where('created_at <= ?', params[:created_before].to_time(:default) ).order("created_at desc")
    else
      @activities = PublicActivity::Activity.where('group_id = ?', Group.friendly.find(params[:id]).id).order("created_at desc")
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

  def search
    if params[:q].present?
      @query = params[:q];
      @search = Sunspot.search [Petition, User] do
          keywords @query
          paginate(:page => params[:page], :per_page => 20)
      end

      @sunspot_search = Sunspot.search Petition, User do |query| 
      query.keywords @query
      query.paginate(:page => params[:page], :per_page => 20)
      end
    else
      flash[:error] = "There was an error with your search request. Please check and try again."
      redirect_to group_path
    end
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    respond_to do |format|
      if @group.save
        @group.users << current_user
        @membership = GroupMembership.where('group_id =?',@group.id)
                  .where('user_id =?',current_user.id).first
        # GroupMembership.where('user_id = #{current_user.id} AND group_id = #{@group.id}').roles=[:admin]
        @membership.roles = [:admin]
        @membership.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.friendly.find(params[:id]) if params[:id].present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name,:content,:private)
    end

    def group_membership_params
      params.require(:group_membership).permit(:user_id, :group_id, :roles => [])
    end

    def authenticate_admin
      unless (current_user.present?)
        authenticate_user!
      end
      unless (current_user.group_memberships.where('group_id =?',@group.id).first.has_role?(:admin))
        flash[:error] = "You don't have permission to access that page."
        redirect_to group_path
      end
    end

  def settings_params
    params.require(:settings).permit(:group_id, :logo, :petitions_required_support_percent, :petitions_expiry_time, :petitions_expiry_time_unit, :motions_delay_before_voting, :motions_delay_before_voting_unit, :motions_voting_duration, :motions_voting_duration_unit, :motions_required_majority_percent)
  end
end

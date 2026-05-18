class MotionsController < ApplicationController
  before_action :set_motion, only: [:show, :edit, :update, :destroy]
  before_action :set_group, only: [:index, :show, :edit, :update, :destroy, :support, :new]
  before_filter :authenticate_user!

  include PanGovCommentable

  # GET /motions
  # GET /motions.json
  def index
    @motions = Motion.where('group_id = ?',@group.id)

    @limit = params[:limit];
    if @limit == nil
      @limit = 10;
    end
    if params[:tag].present? 
       @filterrific = initialize_filterrific(
        Motion.where('group_id = ?',@group.id).tagged_with(params[:tag]),
        params[:filterrific],
        select_options: {
          sorted_by: Motion.options_for_sorted_by
        },
        default_filter_params: {},
      ) or return
      @motions =  Kaminari.paginate_array(@filterrific.find).page(params[:page]).per(@limit)
      @tagged_label = ('Tagged with <span class="text-info">' + params[:tag] + "</span> #{view_context.link_to '&#xf00d;'.html_safe, group_motions_path, :class=>'fa-text-block'}").html_safe    else
      @filterrific = initialize_filterrific(
        Motion.where('group_id = ?',@group.id),
        params[:filterrific],
        select_options: {
          sorted_by: Motion.options_for_sorted_by
        },
        default_filter_params: {},
      ) or return
      @motions =  Kaminari.paginate_array(@filterrific.find).page(params[:page]).per(@limit)
      @tagged_label = 'Tagged with'
    end  
    @tags = Motion.where('group_id = ?',@group.id).tag_counts_on(:tags)

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /motions/1
  # GET /motions/1.json
  def show
    @tags = Motion.tag_counts_on(:tags)
    @comments = Motion.find(params[:id]).comments
    @current_user = current_user
  end

  # GET /motions/new
  def new
    @motion = Motion.new
    @motion.polls.create
  end

  # GET /motions/1/edit
  def edit
  end

  def data
  end

  def poll
  end

  def vote
    @motion = Motion.find(params['id'])
    if (@motion.voting_ends_at.past?)
      flash[:warning] = "Voting on this motion has ended."
      respond_to do |format|
          format.js { }
      end
    else
      @vote_for = vote_params[:vote_for]
      if @vote_for == "true"
         @motion.upvote_from current_user 
       else
         @motion.downvote_from current_user
      end
      # @motion.liked_by current_user
      @motion.create_activity key: 'motion.voted', owner: current_user
      flash[:notice] = "You voted on this motion."
      respond_to do |format|
          format.js { }
      end
    end
  end

  # def voteup
  #   @motion = Motion.find(params['id'])
  #   @motion.liked_by current_user
  #   @motion.create_activity key: 'motion.upvoted', owner: current_user
  #   flash[:notice] = "You voted on this motion."
  #   respond_to do |format|
  #       format.js { }
  #   end
  # end

  # def votedown
  #   @motion = Motion.find(params['id'])
  #   @motion.disliked_by current_user
  #   @motion.create_activity key: 'motion.downvoted', owner: current_user
  #   flash[:notice] = "You voted on this motion."
  #   respond_to do |format|
  #       format.js { }
  #   end
  # end

  # POST /motions
  # POST /motions.json
  def create
    @motion = Motion.new(motion_params)
    Motion.delay(run_at: @motion.voting_ends_at).vote_ended(@motion.id)
    respond_to do |format|
      if @motion.save
        format.html { redirect_to @motion, notice: 'Motion was successfully created.' }
        format.json { render :show, status: :created, location: @motion }
      else
        format.html { render :new }
        format.json { render json: @motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /motions/1
  # PATCH/PUT /motions/1.json
  def update
    respond_to do |format|
      if @motion.update(motion_params)
        format.html { redirect_to @motion, notice: 'Motion was successfully updated.' }
        format.json { render :show, status: :ok, location: @motion }
      else
        format.html { render :edit }
        format.json { render json: @motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /motions/1
  # DELETE /motions/1.json
  def destroy
    @motion.destroy
    respond_to do |format|
      format.html { redirect_to motions_url, notice: 'Motion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_group
      @group = Group.friendly.find(params[:group_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_motion
      @motion = Motion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def motion_params
      params.require(:motion).permit(:name, :content, :petition_id)
    end

     # Never trust parameters from the scary internet, only allow the white list through.
    def vote_params
      params.require(:vote).permit(:vote_for)
    end
end

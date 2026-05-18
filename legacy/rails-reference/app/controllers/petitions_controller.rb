class PetitionsController < ApplicationController
  before_action :set_petition, only: [:show, :edit, :update, :destroy, :support]
  before_action :set_group, only: [:index, :show, :edit, :update, :destroy, :support, :new, :data]
  before_filter :authenticate_user!
  
  include PanGovCommentable

  # GET /petitions
  # GET /petitions.json


  def index 
    @petitions = Petition.where('group_id = ?',@group.id)
    @limit = params[:limit];
    if @limit == nil
      @limit = 10;
    end
    if params[:tag].present? 
       @filterrific = initialize_filterrific(
        Petition.where('group_id = ?',@group.id).tagged_with(params[:tag]),
        params[:filterrific],
        select_options: {
          sorted_by: Petition.options_for_sorted_by
        },
        default_filter_params: {},
      ) or return
      @petitions =  Kaminari.paginate_array(@filterrific.find).page(params[:page]).per(@limit)
      @tagged_label = ('Tagged with <span class="text-info">' + params[:tag] + "</span> #{view_context.link_to '&#xf00d;'.html_safe, group_petitions_path, :class=>'fa-text-block'}").html_safe
    else
      @filterrific = initialize_filterrific(
        Petition.where('group_id = ?',@group.id),
        params[:filterrific],
        select_options: {
          sorted_by: Petition.options_for_sorted_by
        },
        default_filter_params: {},
      ) or return
      @petitions =  Kaminari.paginate_array(@filterrific.find).page(params[:page]).per(@limit)
      @tagged_label = 'Tagged with'
    end 
    # @petitions = @filterrific.find.page(params[:page]).per(10)
    # if params[:tag].present? 
    #   @petitions = Petition.tagged_with(params[:tag])
    # else 
    #   @petitions = Petition.all
    # end  
    @tags = Petition.where('group_id = ?',@group.id).tag_counts_on(:tags)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def data
  end

  def petitions_count
    render partial:'petitions/data/petitions_count'
  end

  def petitions_support_spread
    render partial:'petitions/data/petitions_support_spread'
  end
  
  def show
    @tags = Petition.tag_counts_on(:tags)
    @comments = Petition.find(params[:id]).comments
  end

  # GET /petitions/new
  def new
    @petition = Petition.new
  end

  # GET /petitions/1/edit
  def edit
  end

  # def expire
  #   if @petition.get_upvotes.size >= @petition.required_votes
  #     #petition passes to motion
  #     @motion = Motion.create(name: @petition.name, content: @petition.content, petition_id: @petition.id)
  #   end
  # end

  # POST /petitions
  # POST /petitions.json
  def create
    @group = Group.find(petition_params[:group_id])
    @petition = @group.petitions.new(petition_params)
    @petition.expires_at = Time.now + TimeFormatting.convert_to_seconds(@group.group_setting.petitions_expiry_time.to_f,@group.group_setting.petitions_expiry_time_unit)
    @saved = @petition.save
    Petition.delay(run_at: @petition.expires_at).expire(@group.id, @petition.id)
    respond_to do |format|
      if @saved
        format.html { redirect_to group_petition_path(group_id: @petition.group.slug, id: @petition.id), notice: 'Petition was successfully created.' }
        format.json { render :show, status: :created, location: @petition }
      else
        format.html { render :new }
        format.json { render json: @petition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /petitions/1
  # PATCH/PUT /petitions/1.json
  def update
    respond_to do |format|
      if @petition.update(petition_params)
        format.html { redirect_to @petition, notice: 'Petition was successfully updated.' }
        format.json { render :show, status: :ok, location: @petition }
      else
        format.html { render :edit }
        format.json { render json: @petition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /petitions/1
  # DELETE /petitions/1.json
  def destroy
    @petition.destroy
    respond_to do |format|
      format.html { redirect_to petitions_url, notice: 'Petition was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def support
    @petition = Petition.find(params['id'])
    if (@petition.expires_at.future?)
      @petition.liked_by current_user
      @petition.create_activity key: 'petition.supported', owner: current_user
      flash[:notice] = "You supported this petition."
    else
      flash[:warning] = "Sorry, this petition has already expired."
    end
    respond_to do |format|
        format.js { }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.friendly.find(params[:group_id])
    end
    def set_petition
      @petition = Petition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def petition_params
      params.require(:petition).permit(:name, :content, :creator_id, :tag_list, :expires_at, :group_id)
    end
end

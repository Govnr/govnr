class PetitionsController < ApplicationController
  before_action :set_petition, only: [:show, :edit, :update, :destroy, :support]
  before_filter :authenticate_user!  
  include PanGovCommentable

  # GET /petitions
  # GET /petitions.json
  @petitions = Petition.all

  def index 
   
    @limit = params[:limit];
    if @limit == nil
      @limit = 10;
    end
    if params[:tag].present? 
       @filterrific = initialize_filterrific(
        Petition.tagged_with(params[:tag]),
        params[:filterrific],
        select_options: {
          sorted_by: Petition.options_for_sorted_by
        },
        default_filter_params: {},
      ) or return
      @petitions =  Kaminari.paginate_array(@filterrific.find).page(params[:page]).per(@limit)
      @tagged_label = ('Tagged with <span class="text-info">' + params[:tag] + "</span> #{view_context.link_to '&#xf00d;'.html_safe, petitions_path, :class=>'fa-text-block'}").html_safe
    else
      @filterrific = initialize_filterrific(
        Petition,
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
    @tags = Petition.tag_counts_on(:tags)

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

  # def tagged
  #   if params[:tag].present? 
  #     @petitions = Petition.tagged_with(params[:tag])
  #   else 
  #     @petitions = Petition.all
  #   end  
  # end


  # def tag_cloud
  #     # Petition.find(:first).pins.tag_counts_on(:tags)
  #     @tags = Petition.tag_counts_on(:tags)
  # end

  # GET /petitions/1
  # GET /petitions/1.json
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

  # POST /petitions
  # POST /petitions.json
  def create
    @petition = Petition.new(petition_params)
    @user_id = current_user.id
    respond_to do |format|
      if @petition.save
        format.html { redirect_to @petition, notice: 'Petition was successfully created.' }
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
    @petition.liked_by current_user
    @petition.create_activity key: 'petition.supported', owner: current_user
    flash[:notice] = "You supported this petition."
    respond_to do |format|
        format.js { }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_petition
      @petition = Petition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def petition_params
      params.require(:petition).permit(:name, :content, :creator_id, :tag_list) #:tag_list => []
    end
end

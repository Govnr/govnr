class DraftsController < ApplicationController
 # acts_as_wiki_pages_controller
  before_action :set_draft, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  # Setup @draft instance variable before each action
  before_action :set_draft, only: [:show, :history, :compare, :new, :edit, :update, :destroy, :add_attachment]
  helper_method :show_allowed?, :edit_allowed?, :history_allowed?, :destroy_allowed? # Access control methods are avaliable in views

  include PanGovCommentable
  
  def index
    @limit = params[:limit];
    if @limit == nil
      @limit = 10;
    end
    if params[:tag].present? 
       @filterrific = initialize_filterrific(
        Draft.tagged_with(params[:tag]),
        params[:filterrific],
        select_options: {
          sorted_by: Draft.options_for_sorted_by
        },
        default_filter_params: {},
      ) or return
      @drafts =  Kaminari.paginate_array(@filterrific.find).page(params[:page]).per(@limit)
      @tagged_label = ('Tagged with <span class="text-info">' + params[:tag] + "</span> #{view_context.link_to '&#xf00d;'.html_safe, petitions_path, :class=>'fa-text-block'}").html_safe
    else
      @filterrific = initialize_filterrific(
        Draft,
        params[:filterrific],
        select_options: {
          sorted_by: Draft.options_for_sorted_by
        },
        default_filter_params: {},
      ) or return
      @drafts =  Kaminari.paginate_array(@filterrific.find).page(params[:page]).per(@limit)
      @tagged_label = 'Tagged with'
    end 
    # @petitions = @filterrific.find.page(params[:page]).per(10)
    # if params[:tag].present? 
    #   @petitions = Petition.tagged_with(params[:tag])
    # else 
    #   @petitions = Petition.all
    # end  
    @tags = Draft.tag_counts_on(:tags)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @draft = Draft.new
  end

  def create
    @draft = Draft.new(draft_params)
    respond_to do |format|
      if @draft.save
        format.html { redirect_to @motion, notice: 'Draft was successfully created.' }
        format.json { render :show, status: :created, location: @draft }
      else
        format.html { render :new }
        format.json { render json: @draft.errors, status: :unprocessable_entity }
      end
    end
  end

  def show_allowed?
     current_user ? true : false
  end

  def history_allowed?
     current_user ? true : false
  end

  def edit_allowed?
    current_user ? true : false
  end

  def destroy_allowed?
      @draft.path != '' && admin_user_signed_in? 
      # Allow editing only to admins, and not to root page
  end

  def not_allowed
    redirect_to login_path # Redirect to login_url when user tries something what not allowed
  end

  # def show
  #   return not_allowed unless show_allowed?

  #   #render_template(@draft.new_record? ? 'no' : 'show')
  # end

  def history
    # return not_allowed unless history_allowed?
    @limit = params[:limit];
    @draft = Draft.find(params[:id])
    @versions = Kaminari.paginate_array(@draft.versions).page(params[:page]).per(@limit)
    #@versions = Irwi.config.paginator.paginate(@draft.versions, page: params[:page]) # Paginating them
    # render_template(@draft.new_record? ? 'no' : 'history')
  end

  def compare
    return not_allowed unless history_allowed?

    if @draft.new_record?
      flash[:warning] = "Sorry, this petition has already expired."
      redirect_to @draft
    else
      @versions, @old_version, @new_version = load_paginated_versions(*version_number_params)
    end
  end

  def new
    return not_allowed unless show_allowed? && edit_allowed?

    render_template 'new'
  end

  def edit
    return not_allowed unless show_allowed? && edit_allowed?

    # render_template 'edit'
  end

  def update
    return not_allowed unless params[:draft] && (@draft.new_record? || edit_allowed?) # Check for rights (but not for new record, for it we will use second check only)
    p @draft
    @draft.attributes = draft_params
    p @draft
    return not_allowed unless edit_allowed? # Double check: used beacause action may become invalid after attributes update

    @draft.updater = current_user # Assing user, which updated page
    @draft.creator = current_user if @draft.new_record? # Assign it's creator if it's new page
    @draft.create_activity key: 'draft.updated', owner: current_user
    if !params[:preview] && (params[:cancel] || @draft.save)
      redirect_to url_for(@draft) # redirect to new page's path (if it changed)
    # else
    #   render_template 'edit'
    end
  end

  def destroy
    return not_allowed unless destroy_allowed?

    @draft.destroy

    redirect_to url_for(action: :show)
  end

  def all
    @drafts = Irwi.config.paginator.paginate(page_class, page: params[:page]) # Loading and paginating all pages

    render_template 'all'
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_draft
    @draft = Draft.find(params[:id])
  end
      # Never trust parameters from the scary internet, only allow the white list through.
  def draft_params
    params.require(:draft).permit(:name, :content, :motion_id)
  end

  def load_paginated_versions(old_num, new_num)
    @limit = params[:limit]
    p ">>>>> load_paginated_versions"
    versions = @draft.versions.between(old_num, new_num) # Loading all versions between first and last

    paginated_versions = Kaminari.paginate_array(versions).page(params[:page]).per(@limit) # Paginating them
    p paginated_versions
    new_version = paginated_versions.first.number == new_num ? paginated_versions.first : versions.first # Load next version
    old_version = paginated_versions.last.number == old_num ? paginated_versions.last : versions.last # Load previous version
    p old_version
    p new_version
    [paginated_versions, old_version, new_version]
  end

  def version_number_params
    new_num = params[:new].to_i || @draft.last_version_number # Last version number
    old_num = params[:old].to_i || 1 # First version number

    if new_num < old_num # Swapping them if last < first
      [new_num, old_num]
    else
      [old_num, new_num]
    end
  end

  # Retrieves wiki_page_class for this controller
  def page_class
    self.class.page_class
  end

  # Renders user-specified or default template
  def render_template(template)
    render "#{template_dir template}/#{template}", status: select_template_status(template)
  end

  def select_template_status(template)
    case template
    when 'no' then 404
    when 'not_allowed' then 403
    else 200
    end
  end

  # Method, which called when user tries to visit
  def not_allowed
    render_template 'not_allowed'
  end

  # Check is it allowed for current user to see current page. Designed to be redefined by application programmer
  def show_allowed?
    true
  end

  # Check is it allowed for current user see current page history. Designed to be redefined by application programmer
  def history_allowed?
    show_allowed?
  end

  # Check is it allowed for current user edit current page. Designed to be redefined by application programmer
  def edit_allowed?
    show_allowed?
  end

  # Check is it allowed for current user destroy current page. Designed to be redefined by application programmer
  def destroy_allowed?
    edit_allowed?
  end
end

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  # GET /users
  # GET /users.json
  @users = User.all

  def index
    @limit = params[:limit];
    if @limit == nil
      @limit = 10;
    end
   @filterrific = initialize_filterrific(
      User,
      params[:filterrific],
      select_options: {
        sorted_by: User.options_for_sorted_by
      },
      default_filter_params: {},
    ) or return
    @users =  Kaminari.paginate_array(@filterrific.find).page(params[:page]).per(@limit)
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @activities = PublicActivity::Activity.order("created_at desc")
          .where(owner_type: "User", owner_id: @user.id)
  end

  def following
    @limit = params[:limit];
    if @limit == nil
      @limit = 10;
    end
    @title = "Following"
    @user  = User.find(params[:id])
    @filterrific = initialize_filterrific(
      @user.following,
      params[:filterrific],
      select_options: {
        sorted_by: User.options_for_sorted_by
      },
      default_filter_params: {},
    ) or return
    @users =  Kaminari.paginate_array(@filterrific.find).page(params[:page]).per(@limit)
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :address, :postcode, :photo, :roles => [])
    end
end

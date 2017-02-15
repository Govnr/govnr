class StatutesController < ApplicationController
  before_action :set_statute, only: [:show, :edit, :update, :destroy]

  # GET /statutes
  # GET /statutes.json
  def index
    @statutes = Statute.all
  end

  # GET /statutes/1
  # GET /statutes/1.json
  def show
  end

  # GET /statutes/new
  def new
    @statute = Statute.new
  end

  # GET /statutes/1/edit
  def edit
  end

  # POST /statutes
  # POST /statutes.json
  def create
    @statute = Statute.new(statute_params)

    respond_to do |format|
      if @statute.save
        format.html { redirect_to @statute, notice: 'Statute was successfully created.' }
        format.json { render :show, status: :created, location: @statute }
      else
        format.html { render :new }
        format.json { render json: @statute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /statutes/1
  # PATCH/PUT /statutes/1.json
  def update
    respond_to do |format|
      if @statute.update(statute_params)
        format.html { redirect_to @statute, notice: 'Statute was successfully updated.' }
        format.json { render :show, status: :ok, location: @statute }
      else
        format.html { render :edit }
        format.json { render json: @statute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statutes/1
  # DELETE /statutes/1.json
  def destroy
    @statute.destroy
    respond_to do |format|
      format.html { redirect_to statutes_url, notice: 'Statute was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_statute
      @statute = Statute.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def statute_params
      params.require(:statute).permit(:name, :content, :motion_id)
    end
end

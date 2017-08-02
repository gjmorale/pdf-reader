class CoverPrintsController < ApplicationController
  before_action :set_cover_print, only: [:show, :edit, :update, :destroy]

  # GET /cover_prints
  # GET /cover_prints.json
  def index
    @cover_prints = CoverPrint.all
  end

  # GET /cover_prints/1
  # GET /cover_prints/1.json
  def show
  end

  # GET /cover_prints/new
  def new
    @cover_print = CoverPrint.new
  end

  # GET /cover_prints/1/edit
  def edit
  end

  # POST /cover_prints
  # POST /cover_prints.json
  def create
    @cover_print = CoverPrint.new(cover_print_params)

    respond_to do |format|
      if @cover_print.save
        format.html { redirect_to @cover_print, notice: 'Cover print was successfully created.' }
        format.json { render :show, status: :created, location: @cover_print }
      else
        format.html { render :new }
        format.json { render json: @cover_print.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cover_prints/1
  # PATCH/PUT /cover_prints/1.json
  def update
    respond_to do |format|
      if @cover_print.update(cover_print_params)
        format.html { redirect_to @cover_print, notice: 'Cover print was successfully updated.' }
        format.json { render :show, status: :ok, location: @cover_print }
      else
        format.html { render :edit }
        format.json { render json: @cover_print.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cover_prints/1
  # DELETE /cover_prints/1.json
  def destroy
    @cover_print.destroy
    respond_to do |format|
      format.html { redirect_to cover_prints_url, notice: 'Cover print was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cover_print
      @cover_print = CoverPrint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cover_print_params
      params.require(:cover_print).permit(:first_filter, :second_filter, :bank_id, :meta_print_id)
    end
end

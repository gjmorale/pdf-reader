class MetaPrintsController < ApplicationController
  before_action :set_meta_print, only: [:show, :edit, :update, :destroy]

  # GET /meta_prints
  # GET /meta_prints.json
  def index
    @meta_prints = MetaPrint.all
  end

  # GET /meta_prints/1
  # GET /meta_prints/1.json
  def show
  end

  # GET /meta_prints/new
  def new
    @meta_print = MetaPrint.new
  end

  # GET /meta_prints/1/edit
  def edit
  end

  # POST /meta_prints
  # POST /meta_prints.json
  def create
    @meta_print = MetaPrint.new(meta_print_params)

    respond_to do |format|
      if @meta_print.save
        format.html { redirect_to @meta_print, notice: 'Meta print was successfully created.' }
        format.json { render :show, status: :created, location: @meta_print }
      else
        format.html { render :new }
        format.json { render json: @meta_print.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /meta_prints/1
  # PATCH/PUT /meta_prints/1.json
  def update
    respond_to do |format|
      if @meta_print.update(meta_print_params)
        format.html { redirect_to @meta_print, notice: 'Meta print was successfully updated.' }
        format.json { render :show, status: :ok, location: @meta_print }
      else
        format.html { render :edit }
        format.json { render json: @meta_print.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meta_prints/1
  # DELETE /meta_prints/1.json
  def destroy
    @meta_print.destroy
    respond_to do |format|
      format.html { redirect_to meta_prints_url, notice: 'Meta print was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_meta_print
      @meta_print = MetaPrint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def meta_print_params
      params.require(:meta_print).permit(:creator, :producer, :bank_id)
    end
end

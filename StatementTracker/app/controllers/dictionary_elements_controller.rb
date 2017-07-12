class DictionaryElementsController < ApplicationController
  before_action :set_dictionary_element, only: [:show, :edit, :update, :destroy]

  # GET /dictionary_elements
  # GET /dictionary_elements.json
  def index
    @dictionary_elements = DictionaryElement.all
  end

  # GET /dictionary_elements/1
  # GET /dictionary_elements/1.json
  def show
  end

  # GET /dictionary_elements/new
  def new
    @dictionary_element = DictionaryElement.new
  end

  # GET /dictionary_elements/1/edit
  def edit
  end

  # POST /dictionary_elements
  # POST /dictionary_elements.json
  def create
    @dictionary_element = DictionaryElement.new(dictionary_element_params)

    respond_to do |format|
      if @dictionary_element.save
        format.html { redirect_to @dictionary_element, notice: 'Dictionary element was successfully created.' }
        format.json { render :show, status: :created, location: @dictionary_element }
      else
        format.html { render :new }
        format.json { render json: @dictionary_element.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dictionary_elements/1
  # PATCH/PUT /dictionary_elements/1.json
  def update
    respond_to do |format|
      if @dictionary_element.update(dictionary_element_params)
        format.html { redirect_to @dictionary_element, notice: 'Dictionary element was successfully updated.' }
        format.json { render :show, status: :ok, location: @dictionary_element }
      else
        format.html { render :edit }
        format.json { render json: @dictionary_element.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dictionary_elements/1
  # DELETE /dictionary_elements/1.json
  def destroy
    @dictionary_element.destroy
    respond_to do |format|
      format.html { redirect_to dictionary_elements_url, notice: 'Dictionary element was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dictionary_element
      @dictionary_element = DictionaryElement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dictionary_element_params
      params.require(:dictionary_element).permit(:element_id, :element_type, :dictionary_id)
    end
end

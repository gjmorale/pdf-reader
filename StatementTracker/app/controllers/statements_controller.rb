class StatementsController < ApplicationController
  before_action :set_statement, only: [:show, :edit, :update, :destroy]
  before_action :search_params, only: [:filter]
  before_action :set_search_params, only: [:index]

  # GET /statements
  # GET /statements.json
  def index
    @societies = Society.filter @search_params if @search_params
    @societies = Society.treefy @societies
  end

  def filter
    redirect_to statements_path
  end

  def reload
    Tax.reload(params[:reload_from].to_date, params[:reload_to].to_date)
    redirect_to statements_path
  end

  # GET /statements/1
  # GET /statements/1.json
  def show
  end

  def new
    @noticed_statements = FileManager.read_new @client
    render :index
  end

  # GET /statements/1/edit
  def edit
  end

  # PATCH/PUT /statements/1
  # PATCH/PUT /statements/1.json
  def update
    respond_to do |format|
      if @statement.update(statement_params)
        format.html { redirect_to @statement, notice: 'Statement was successfully updated.' }
        format.json { render :show, status: :ok, location: @statement }
      else
        format.html { render :edit }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statements/1
  # DELETE /statements/1.json
  def destroy
    @statement.destroy
    respond_to do |format|
      format.html { redirect_to statements_url, notice: 'Statement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_statement
      @statement = Statement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def statement_params
      params.require(:statement).permit(:file_name, :sequence_id, :bank_id, :handler_id, :d_filed, :d_open, :d_close, :d_read, :status)
    end
end

class StatementsController < ApplicationController
  before_action :set_statement, only: [:show, :edit, :update, :destroy]
  before_action :set_statements, only: [:reset]

  # GET /statements
  # GET /statements.json
  def index
    @noticed_statements = Statement.joins(:status).where("statement_statuses.code = ?", StatementStatus::NOTICED)
    @indexed_statements = Statement.joins(:status).where("statement_statuses.code = ?", StatementStatus::INDEXED)
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
  def reset
    puts @statements
    render 'index'
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
    # Use callbacks to share common setup or constraints between actions.
    def set_statements
      @statements = []
      puts params.inspect
      raise
      params[:statements].each do |key, value|
        @statements << Statement.find(key.to_i) if value[:check]
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def statement_params
      params.require(:statement).permit(:file_name, :sequence_id, :bank_id, :handler_id, :d_filed, :d_open, :d_close, :d_read, :status)
    end
end

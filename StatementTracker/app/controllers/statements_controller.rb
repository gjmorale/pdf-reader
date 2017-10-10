class StatementsController < ApplicationController
  before_action :set_statement, only: [:show, :edit, :update, :destroy, :assign, :unassign, :open]
  before_action :search_params, only: [:filter]
  before_action :set_search_params, only: [:index]
  before_action :set_statements, only: [:batch_update, :upgrade, :downgrade]

  # GET /statements
  # GET /statements.json
  def index
    @societies = Society.filter @search_params if @search_params
    @societies = Society.all
    @societies = Society.treefy @societies
  end

  def filter
    redirect_back(fallback_location: statements_path)
  end

  def reload
    date_from = Date.new(*(params[:reload_from].map{|k,v| v.to_i}))
    date_to = Date.new(*(params[:reload_to].map{|k,v| v.to_i}))
    Statement.destroy_invalid_files
    Tax.reload(date_from, date_to)
    redirect_back(fallback_location: statements_path)
  end

  # GET /statements/1
  # GET /statements/1.json
  def show
  end

  def open
    path = "#{current_user.role.repo_path}/#{@statement.path}"
    redirect_to path
  end

  def assign
    if current_user and current_user.role.is_a? Handler
      assigned = @statement.assign_to(current_user.role)
      respond_to do |format|
        format.html do 
          flash[:notice] = "Cartola asignada a #{current_user.role.short_name}"
          redirect_back(fallback_location: statement_path(@statement))
        end
        format.js do 
          @targets = assigned ? [@statement] : []
          @new_handler = @statement.handler.short_name
          render 'nodes/update_statements'
        end
      end
    else
      redirect_to new_user_session_path
    end
  end

  def unassign
    if current_user and current_user.role.is_a? Handler
      assigned = @statement.handler
      if assigned and assigned == current_user.role
        @statement.handler = nil
        @statement.save
        flash[:notice] = "Cartola liberada"
      else
        flash[:alert] = "No se pudo liberar la cartola"
      end
      redirect_back(fallback_location: handler_path(current_user.role))
    else
      redirect_to new_user_session_path
    end
  end

  def new
    #TODO?
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

  def batch_update
    @statements.each do |statement|
      statement.update_from_form @statements_params[statement.id]
    end
    complete_statements
    render 'handlers/edit'
  end

  def upgrade
    @statements.each do |statement|
      statement.upgrade
    end
    redirect_to @handler
  end

  def downgrade
    @statements.each do |statement|
      statement.downgrade
    end
    redirect_to @handler
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
      params.require(:statement).permit(:file_name, :path)
    end

    def set_statements
      redirect_to users_sign_in_path unless current_user and 
        @handler = current_user.role and 
        @handler.is_a? Handler

      @statements = []
      @statements_params = {}
      if params[:statements]
        params[:statements].each do |key, value|
          if value[:check] and statement = Statement.find(key.to_i) and statement.handler == @handler
            @statements << statement 
            @statements_params[statement.id] = value.permit(
              :file_name,
              :society_id,
              :bank_id,
              :date,
              :periodicity)
          end
        end
      end
    end

    def complete_statements
      ids = @statements.map{|s| s.id}
      other_statements = @handler.statements.where.not(id: ids)
      @statements += other_statements
    end
end

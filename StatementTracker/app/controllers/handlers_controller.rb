class HandlersController < ApplicationController
  before_action :set_handler, only: [:show, :edit, :update, :destroy, :assign, :unassign, :update_statements, :auto_statements, :index_statements, :fit_statements, :reload_statements]
  before_action :set_statements, only: [:assign, :unassign, :update_statements, :auto_statements, :index_statements, :fit_statements, :reload_statements]

  # GET /handlers
  # GET /handlers.json
  def index
    @handlers = Handler.all
  end

  # GET /handlers/1
  # GET /handlers/1.json
  def show
    @statements = Statement.unassigned
  end

  def assign
    handler = Handler.first
    @statements.select{|s| s.handler.nil?}.each do |statement|
      statement.assign_to handler
    end
    redirect_to handler #Update with current_user
  end

  def unassign
    handler = Handler.first
    @statements.select{|s| s.handler == handler}.each do |statement|
      statement.unassign_handler
    end
    redirect_to handler #Update with current_user
  end

  def reload_statements
    handler = Handler.first #Update with current_user
    @statements.select{|s| s.handler == handler}.each do |statement|
      handler.renotice statement
    end
    #redirect_to edit_handler_path(handler) #Update with current_user
    complete_statements
    render :edit
  end

  def auto_statements
    handler = Handler.first #Update with current_user
    @statements.select{|s| s.handler == handler}.each do |statement|
      handler.auto statement
    end
    #redirect_to edit_handler_path(handler) #Update with current_user
    complete_statements
    render :edit
  end

  def index_statements
    handler = Handler.first #Update with current_user
    @statements.select{|s| s.handler == handler}.each do |statement|
      handler.index statement, 
        params[:statements][statement.id.to_s][:bank_id]
    end
    #redirect_to edit_handler_path(handler) #Update with current_user
    complete_statements
    render :edit
  end

  def fit_statements
    handler = Handler.first #Update with current_user
    @statements.select{|s| s.handler == handler}.each do |statement|
      handler.fit_in_seq statement, 
        params[:statements][statement.id.to_s][:society_id],
        params[:statements][statement.id.to_s][:d_open],
        params[:statements][statement.id.to_s][:d_close]
    end
    #redirect_to edit_handler_path(handler) #Update with current_user
    complete_statements
    render :edit
  end

  # GET /handlers/new
  def new
    @handler = Handler.new
  end

  # GET /handlers/1/edit
  def edit
    @statements = @handler.statements
  end

  # POST /handlers
  # POST /handlers.json
  def create
    @handler = Handler.new(handler_params)

    respond_to do |format|
      if @handler.save
        format.html { redirect_to @handler, notice: 'Handler was successfully created.' }
        format.json { render :show, status: :created, location: @handler }
      else
        format.html { render :new }
        format.json { render json: @handler.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /handlers/1
  # PATCH/PUT /handlers/1.json
  def update
    respond_to do |format|
      if @handler.update(handler_params)
        format.html { redirect_to @handler, notice: 'Handler was successfully updated.' }
        format.json { render :show, status: :ok, location: @handler }
      else
        format.html { render :edit }
        format.json { render json: @handler.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /handlers/1
  # DELETE /handlers/1.json
  def destroy
    @handler.destroy
    respond_to do |format|
      format.html { redirect_to handlers_url, notice: 'Handler was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_handler
      @handler = Handler.find(params[:id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_statements
      @statements = []
      if params[:statements]
        params[:statements].each do |key, value|
          @statements << Statement.find(key.to_i) if value[:check]
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def handler_params
      params.require(:handler).permit(:repo_path, :local_path, :short_name, :name, eq_societies_attributes: [:id, :society_id, :text])
    end

    def eq_societies_params
      filter = params.require(:eq_societies)
      new_params = {}
      filter.each do |key, value|
        new_params[key] = value.permit(:text, :society_id)
      end
      new_params
    end

    def complete_statements
      ids = @statements.map{|s| s.id}
      other_statements = @handler.statements.where.not(id: ids)
      @statements += other_statements
    end
end

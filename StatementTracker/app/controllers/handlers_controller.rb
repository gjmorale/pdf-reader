class HandlersController < ApplicationController
  before_action :set_handler, only: [:show, :edit, :update, :destroy, :unassign_all]
  before_action :set_statements, only: [:assign]
  before_action :own_statements, only: [:unassign, :update_statements, :auto_statements, :index_statements, :fit_statements, :reload_statements]
  before_action :authenticate_user!, except: [:index, :new, :create, :destroy]
  # GET /handlers
  # GET /handlers.json
  def index
    @handlers = Handler.all
  end

  # GET /handlers/1
  # GET /handlers/1.json
  def show
    repo = Paths::DROPBOX + @handler.local_path
    @local_files = Dir[repo + "/**/*.*"].map{|f| f.sub(Paths::DROPBOX,'')}
  end

  def assign
    @statements.each do |statement|
      statement.assign_to @handler
    end
    redirect_to @handler
  end

  def unassign
    @statements.each do |statement|
      statement.unassign_handler
    end
    redirect_to @handler
  end

  def unassign_all
    if current_user and current_user.role.is_a? Handler
      @handler.unassign_all
      respond_to do |format|
        format.html { redirect_to @handler, notice: 'Las cartolas fueron soltadas' }
        format.json { render :show, status: :ok, location: @handler }
      end        
    else
      redirect_to new_user_session_path
    end
  end

  def reload_statements
    @statements.each do |statement|
      @handler.renotice statement
    end
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

    def set_statements
      set_handler
      puts "#{current_user.role} VS #{@handler}"
      return false unless current_user.role == @handler
      @statements = []
      if params[:statements]
        params[:statements].each do |key, value|
          @statements << Statement.find(key.to_i) if value[:check]
        end
      end
    end

    def own_statements
      return false unless set_statements
      @statements = @statements.select{|s| s.handler == @handler}
      puts "STATEMENTS! (#{@statements.count}) HANDLER: #{@handler}"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def handler_params
      params.require(:handler).permit(:repo_path, :local_path, :short_name)
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

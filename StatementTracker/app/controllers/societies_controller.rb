class SocietiesController < ApplicationController
  before_action :set_society, only: [:show, :edit, :update, :destroy, :time_nodes, :if_nodes, :statement_nodes]
  before_action :search_params, only: [:filter]
  before_action :set_search_params, only: [:index, :show, :time_nodes, :if_nodes, :statement_nodes]

  # GET /societies
  # GET /societies.json
  def index
    @societies = Society.roots
    @societies = Society.filter @search_params if @search_params
    @societies = Society.treefy @societies
    respond_to do |format|
      format.html
      format.js do 
      end
    end
  end

  def filter
    redirect_to societies_path
  end

  # GET /societies/1
  # GET /societies/1.json
  def show
    respond_to do |format|
      format.html
      format.js do 
        @element = @society
        @node_template = 'societies/node'
        @children = @society.filter @search_params
        @progress = '10'
        @children = Society.treefy @children
        render 'nodes/navigation'
      end
    end
  end

  def time_nodes
    respond_to do |format|
      format.html
      format.js do 
        @element = @society
        @node_template = 'sequences/node'
        @children = @society.time_nodes @search_params
        @auto_open = true
        render 'nodes/navigation'
      end
    end
  end

  def if_nodes
    respond_to do |format|
      format.html
      format.js do 
        @element = @society
        @node_template = 'taxes/node'
        @children = @society.if_nodes @search_params
        @auto_open = true
        render 'nodes/navigation'
      end
    end
  end

  def statement_nodes
    respond_to do |format|
      format.html
      format.js do 
        @element = @society
        @node_template = 'statements/node'
        @children = @society.statement_nodes @search_params
        #@progress = StatementStatus.progress @children.average("statement_statuses.code")
        @auto_open = true
        render 'nodes/navigation'
      end
    end
  end

  # GET /societies/new
  def new
    @society = Society.new
  end

  # GET /societies/1/edit
  def edit
  end

  # POST /societies
  # POST /societies.json
  def create
    @society = Society.new(society_params)

    respond_to do |format|
      if @society.save
        format.html { redirect_to @society, notice: 'Society was successfully created.' }
        format.json { render :show, status: :created, location: @society }
      else
        format.html { render :new }
        format.json { render json: @society.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /societies/1
  # PATCH/PUT /societies/1.json
  def update
    respond_to do |format|
      if @society.update(society_params)
        format.html { redirect_to @society, notice: 'Society was successfully updated.' }
        format.json { render :show, status: :ok, location: @society }
      else
        format.html { render :edit }
        format.json { render json: @society.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /societies/1
  # DELETE /societies/1.json
  def destroy
    @society.destroy
    respond_to do |format|
      format.html { redirect_to societies_url, notice: 'Society was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_society
      @society = Society.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def society_params
      params.require(:society).permit(:name, :rut, :parent_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      @search_params = SearchParams.new(params[:search_params])
      cookies[:search] = {value: @search_params.serialize, expires: 10.hours.from_now}
      puts "COOKIES: #{cookies[:search].inspect}"
    end
end

class SocietiesController < ApplicationController
  before_action :set_society, only: [:show, :edit, :update, :destroy, :time_nodes, :if_nodes, :statement_nodes, :close]
  before_action :search_params, only: [:filter]
  before_action :set_search_params, only: [:time_nodes, :if_nodes, :statement_nodes, :seed]
  before_action :set_date_params, only: [:progress, :close]

  # GET /societies
  # GET /societies.json
  def index
    @societies = Society.roots
  end

  def filter
    redirect_to societies_path
  end

  def reload
    FileManager.load_societies
    redirect_to societies_url
  end

  def progress
    set_society if params[:id]
    @societies = @society ? @society.children : Society.roots
    @societies = @societies.where(active: true) if @societies
    @taxes = @society.taxes if @society and @society.leaf?
    @taxes = @taxes.where(active: true) if @taxes
  end

  # GET /societies/1
  # GET /societies/1.json
  def show
    respond_to do |format|
      format.html
      format.js do 
        set_search_params
        @element = @society
        if params[:status] and params[:status] == "close"
          render 'nodes/navigation'
        else
          if @element.leaf?        
            @node_template = 'statements/node'
            @children = @society.statement_nodes @search_params
            render 'nodes/navigation'
          else
            @node_template = 'societies/node'
            @children = @society.filter @search_params
            @children = @society.treefy @children
            render 'nodes/navigation'
          end
        end
      end
    end
  end

  def time_nodes
    respond_to do |format|
      format.html
      format.js do 
        @element = @society
        @node_template = 'sequences/node'
        @children = @society.all_times @search_params
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
        @children = @society.all_ifs @search_params
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
        @children = @society.all_statements @search_params
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

  def close
    @society.close @date_params
    flash[:notice] = "Cuentas de #{@society.name} cerradas"
    fallback = @society.parent ? progress_society_url(@society.parent) : progress_societies_url
    redirect_back(fallback_location: fallback)
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
      params.require(:society).permit(:name, :rut, :parent_id, 
        source_path_attributes: [:path],
        taxes_attributes: [:bank_id, 
                          :periodicity, 
                          :quantity, 
                          :optional, 
                          :_destroy,
                          :id, 
                          source_paths_attributes: [:id, :path]
                          ],
        children_attributes: [:name,
                              :rut,
                              :id,
                              :_destroy],
        checkmovs_attributes: [:path,
                               :id,
                               :_destroy]
                              )
    end
end
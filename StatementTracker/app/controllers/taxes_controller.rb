class TaxesController < ApplicationController
  before_action :set_tax, only: [:show, :edit, :update, :destroy, :time_nodes, :progress, :adjust, :close]
  before_action :set_search_params, only: [:show, :time_nodes]
  before_action :set_date_params, only: [:progress, :adjust, :close]

  # GET /taxes
  # GET /taxes.json
  def index
    @taxes = Tax.all
  end

  # GET /taxes/1
  # GET /taxes/1.json
  def show
    respond_to do |format|
      format.html
      format.js do 
        @element = @tax
        @node_template = 'statements/node'
        @children = @tax.filter @search_params
        render 'nodes/navigation'
      end
    end
  end

  def progress
    @tax
    @statements = @tax.dated_statements @date_params
  end

  def time_nodes
    respond_to do |format|
      format.html
      format.js do 
        @element = @tax
        @node_template = 'sequences/node'
        @children = @tax.time_nodes @search_params
        @auto_open = true
        render 'nodes/navigation'
      end
    end
  end

  def adjust
    seq = @tax.sequence(@date_params)
    seq ||= Sequence.new(date: @date_params.date, tax: @tax)
    seq.quantity = seq.statements.size
    if seq.save
      flash[:notice] = "Cuenta #{@tax.bank} de #{@tax.society} al #{seq.date} ajustada a #{seq.quantity} documentos"
    else
      flash[:alert] = "Cuenta #{@tax.bank} de #{@tax.society} al #{seq.date} no se pudo ajustar"
    end
    redirect_back(fallback_location: progress_society_url(@tax.society))
  end

  def close
    @tax.quantity = 0
    @tax.save
    if seq = @tax.sequence(@date_params)
      seq.quantity = seq.statements.size
      seq.save
    end
    flash[:notice] = "Cuenta #{@tax.bank} de #{@tax.society} cerrada"
    flash[:notice] << " al #{seq.date}" if seq
    redirect_back(fallback_location: progress_society_url(@tax.society))
  end

  # GET /taxes/new
  def new
    @tax = Tax.new
  end

  # GET /taxes/1/edit
  def edit
  end

  # POST /taxes
  # POST /taxes.json
  def create
    @tax = Tax.new(tax_params)

    respond_to do |format|
      if @tax.save
        format.html { redirect_to @tax, notice: 'Tax was successfully created.' }
        format.json { render :show, status: :created, location: @tax }
      else
        format.html { render :new }
        format.json { render json: @tax.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxes/1
  # PATCH/PUT /taxes/1.json
  def update
    respond_to do |format|
      if @tax.update(tax_params)
        format.html { redirect_to @tax, notice: 'Tax was successfully updated.' }
        format.json { render :show, status: :ok, location: @tax }
      else
        format.html { render :edit }
        format.json { render json: @tax.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxes/1
  # DELETE /taxes/1.json
  def destroy
    @tax.destroy
    respond_to do |format|
      format.html { redirect_to taxes_url, notice: 'Tax was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tax
      @tax = Tax.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tax_params
      params.require(:tax).permit(:bank_id, :society_id, :quantity, :periodicity,
          source_paths_attributes: [:id, :path]
        )
    end
end

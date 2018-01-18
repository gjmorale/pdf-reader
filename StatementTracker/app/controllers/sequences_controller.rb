class SequencesController < ApplicationController
  before_action :set_sequence, only: [:show, :edit, :update, :destroy, :assign_all]
  before_action :set_global_params, only: [:show]
  before_action :date_params, only: [:filter]

  # GET /sequences
  # GET /sequences.json
  def index
    @sequences = Sequence.all
  end

  # GET /sequences/1
  # GET /sequences/1.json
  def show
    respond_to do |format|
      format.html
      format.js do 
        @element = @sequence
        @node_template = 'statements/node'
        @children = @sequence.filter @search_params
        render 'nodes/navigation'
      end
    end
  end

  # GET /sequences/new
  def new
    @sequence = Sequence.new
  end

  # GET /sequences/1/edit
  def edit
  end

  def filter
    redirect_back(fallback_location: root_url)
  end

  # GET /sequences/1/assign_all
  def assign_all
    if current_user and current_user.role.is_a? Handler
      @sequence.assign_all(current_user.role)
      respond_to do |format|
        format.html do 
          flash[:notice] = "Cartolas asignadas a #{current_user.role.short_name}"
          redirect_back(fallback_location: sequences_path(@sequence))
        end
        format.js do
          @targets = @sequence.statements
          render 'nodes/update_statements' 
        end
      end          
    else
      redirect_to new_user_session_path
    end
  end

  # POST /sequences
  # POST /sequences.json
  def create
    @sequence = Sequence.new(sequence_params)

    respond_to do |format|
      if @sequence.save
        format.html { redirect_to @sequence, notice: 'Sequence was successfully created.' }
        format.json { render :show, status: :created, location: @sequence }
      else
        format.html { render :new }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sequences/1
  # PATCH/PUT /sequences/1.json
  def update
    respond_to do |format|
      if @sequence.update(sequence_params)
        format.html { redirect_to @sequence, notice: 'Sequence was successfully updated.' }
        format.json { render :show, status: :ok, location: @sequence }
      else
        format.html { render :edit }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sequences/1
  # DELETE /sequences/1.json
  def destroy
    @sequence.destroy
    respond_to do |format|
      format.html { redirect_to sequences_url, notice: 'Sequence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sequence
      @sequence = Sequence.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sequence_params
      params.require(:sequence).permit(:tax_id, :year, :month, :week, :day)
    end
    
end

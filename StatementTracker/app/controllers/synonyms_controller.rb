class SynonymsController < ApplicationController
	before_action :set_synonym

	def destroy
    @synonym.destroy
	    respond_to do |format|
	      format.html { redirect_to bank_url(@bank), notice: 'Synonym was successfully destroyed.' }
	      format.json { head :no_content }
	    end
	end

	private

		def set_synonym
			@synonym = Synonym.find(params[:id])
			@bank = @synonym.listable
		end

end

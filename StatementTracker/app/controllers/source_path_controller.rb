class SourcePathController < ApplicationController
	before_action :set_source_path

	def destroy
    @source_path.destroy
	    respond_to do |format|
	      format.html { redirect_to tax_url(@tax), notice: 'Source path was successfully destroyed.' }
	      format.json { head :no_content }
	    end
	end

	private

		def set_source_path
			@source_path = SourcePath.find(params[:id])
			@tax = @source_path.sourceable
		end
end

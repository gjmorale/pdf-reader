class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  #https://stackoverflow.com/questions/20126106/devise-error-email-cant-be-blank
  before_action :configure_permitted_parameters, if: :devise_controller?

    def set_search_params
      @search_params = SearchParams.deserialize cookies[:search]
      puts "SEARCH: #{@search_params.inspect}"
    end

	protected
	
		def configure_permitted_parameters
		  devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :password, :password_confirmation])
		end
end

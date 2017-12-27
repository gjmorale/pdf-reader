class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  #https://stackoverflow.com/questions/20126106/devise-error-email-cant-be-blank
  before_action :configure_permitted_parameters, if: :devise_controller?

    def set_search_params
      @search_params ||= SearchParams.deserialize cookies[:search]
    end

    def search_params
      @search_params = SearchParams.new(params[:search_params])
      cookies[:search] = {value: @search_params.serialize, expires: 40.days.from_now}
    end

    def set_date_params
      @date_params ||= DateParams.deserialize cookies[:date]
    end

    def date_params
      @date_params = DateParams.new(params[:date_params])
      cookies[:date] = {value: @date_params.serialize, expires: 40.days.from_now}
    end

  protected

    def after_sign_in_path_for(resource)
      current_user
    end
  
		def configure_permitted_parameters
		  devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :password, :password_confirmation])
		end
end
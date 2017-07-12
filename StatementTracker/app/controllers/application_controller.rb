class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

    def set_search_params
      @search_params = SearchParams.deserialize cookies[:search]
      puts "SEARCH: #{@search_params.inspect}"
    end
end

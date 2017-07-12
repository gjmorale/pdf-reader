class FileManagerController < ApplicationController
  def update
  end

  def new
  	@statements = FileManager.read_new @client
  	render 'statements/index'
  end

  def index
  end
end

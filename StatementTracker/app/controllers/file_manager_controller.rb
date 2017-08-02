class FileManagerController < ApplicationController
  def update
  end

  def new
  	@statements = FileManager.read_new @client
  	puts "STATEMENTS #{@statements}"
  	render 'statements/index'
  end

  def index
  	@files = Dir[Paths::SEED + "/*"]
  	@prev_dir = Paths::SEED
  	puts "files in #{Paths::SEED}/* ... #{@files}"
  	render 'static_pages/test'
  end

  def open
  	@prev_dir = Paths::SEED
  	@base_dir = params[:route] || Paths::SEED
  	if prev_dir = @base_dir.gsub(Paths::SEED+"/", "")
  		puts "PREV DIR: #{prev_dir}"
  		prev_dir = prev_dir.split('/')
  		if prev_dir.any? and prev_dir.size > 1
	  		prev_dir = prev_dir.any? ? prev_dir[-2] : ""
	  		prev_dir = "#{Paths::SEED}/#{prev_dir}"
	  		@prev_dir = prev_dir if Dir.exist? prev_dir
  		end
  	end
  	@files = []
  	@files = Dir[@base_dir + "/*"] if Dir.exist? @base_dir
  	puts "files in #{@base_dir}/* ... #{@files}"
  	render 'static_pages/test'
  end

  def learn
  	puts "LEARNING!!"
  	@meta_prints = FileManager.learn_from_seeds
  	render 'meta_prints/index'
  end

end

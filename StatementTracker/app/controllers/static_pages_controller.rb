class StaticPagesController < ApplicationController
  before_action :set_search_params, only: [:activity]

  def test
  end

  def guide
  end

  def activity
  	@statements = @search_params.filter Statement.joins(sequence: [tax: [:society, :bank]]).all
  	@statements = @statements.order(created_at: :desc)
  end
end

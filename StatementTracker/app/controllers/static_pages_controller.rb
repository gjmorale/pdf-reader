class StaticPagesController < ApplicationController
  before_action :set_global_params, only: [:activity]

  def test
  	@elements = StatementStatus.all
  	@element_id = :id
  	@element_label = :message
  end

  def guide
  end

  def activity
  	@statements = @search_params.filter Statement.joins(sequence: [tax: [:society, :bank]]).all
  	@statements = @statements.order(created_at: :desc)
  end
end

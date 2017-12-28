class AddColumnStartDateToSequences < ActiveRecord::Migration[5.0]
  def change
    add_column :sequences, :start_date, :date
  end
end

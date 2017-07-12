class CreateStatementStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :statement_statuses do |t|
      t.integer :code
      t.integer :progress
      t.string :message

      t.timestamps
    end
  end
end

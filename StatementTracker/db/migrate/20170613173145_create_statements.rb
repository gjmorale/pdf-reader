class CreateStatements < ActiveRecord::Migration[5.0]
  def change
    create_table :statements do |t|
      t.string :file_name
      t.string :path
      t.belongs_to :sequence, foreign_key: true
      t.belongs_to :handler, foreign_key: true
      t.date :d_filed
      t.belongs_to :status, references: :statement_statuses
      t.string :file_hash

      t.timestamps
    end
    add_foreign_key :statements, :statement_statuses, column: :status_id
    add_index :statements, :file_hash, unique: true
  end
end

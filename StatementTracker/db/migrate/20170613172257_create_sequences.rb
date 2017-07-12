class CreateSequences < ActiveRecord::Migration[5.0]
  def change
    create_table :sequences do |t|
      t.belongs_to :tax, foreign_key: true
      t.integer :year, default: 0
      t.integer :month, default: 0
      t.integer :week, default: 0
      t.integer :day, default: 0

      t.timestamps
    end
    add_index :sequences, ["tax_id","year","month","week","day"], unique: true
  end
end

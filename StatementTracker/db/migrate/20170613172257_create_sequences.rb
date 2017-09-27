class CreateSequences < ActiveRecord::Migration[5.0]
  def change
    create_table :sequences do |t|
      t.belongs_to :tax, foreign_key: true
      t.date :date
      t.integer :quantity
      t.integer :optional

      t.timestamps
    end
    add_index :sequences, [:tax_id,:date], unique: true
  end
end

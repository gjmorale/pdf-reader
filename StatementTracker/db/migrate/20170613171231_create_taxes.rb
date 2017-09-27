class CreateTaxes < ActiveRecord::Migration[5.0]
  def change
    create_table :taxes do |t|
      t.belongs_to :bank, foreign_key: true
      t.belongs_to :society, foreign_key: true
      t.integer :quantity, default: 0
      t.integer :optional, default: 0
      t.string :periodicity

      t.timestamps
    end
  end
end

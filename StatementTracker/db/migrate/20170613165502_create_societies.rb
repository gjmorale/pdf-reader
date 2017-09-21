class CreateSocieties < ActiveRecord::Migration[5.0]
  def change
    create_table :societies do |t|
      t.string :name
      t.string :rut
      t.belongs_to :parent, references: :societies

      t.timestamps
    end
    add_foreign_key :societies, :societies, column: :parent_id
    add_index :societies, [:name, :parent_id], unique: true
  end
end

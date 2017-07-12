class CreateBanks < ActiveRecord::Migration[5.0]
  def change
    create_table :banks do |t|
      t.string :name
      t.string :folder_name
      t.string :code_name

      t.timestamps
    end
    add_index :banks, :folder_name, unique: true
    add_index :banks, :code_name, unique: true
  end
end

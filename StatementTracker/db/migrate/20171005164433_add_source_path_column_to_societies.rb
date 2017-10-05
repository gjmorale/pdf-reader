class AddSourcePathColumnToSocieties < ActiveRecord::Migration[5.0]
  def change
    add_column :societies, :source_path, :string
  end
end

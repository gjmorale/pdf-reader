class RemoveSourcePathColumnFromSocieties < ActiveRecord::Migration[5.0]
  def change
    remove_column :societies, :source_path, :string
  end
end

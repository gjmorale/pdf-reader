class ChangeColumnTaxIdToPolymorphic < ActiveRecord::Migration[5.0]
  def change
  	rename_column :source_paths, :tax_id, :sourceable_id
  	add_column :source_paths, :sourceable_type, :string
  	add_column :source_paths, :key, :string
  end
end

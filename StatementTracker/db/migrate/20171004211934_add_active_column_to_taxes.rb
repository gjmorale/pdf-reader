class AddActiveColumnToTaxes < ActiveRecord::Migration[5.0]
  def change
    add_column :taxes, :active, :boolean, default: true
  end
end

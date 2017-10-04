class AddActiveColumnToSociety < ActiveRecord::Migration[5.0]
  def change
    add_column :societies, :active, :boolean, default: true
  end
end

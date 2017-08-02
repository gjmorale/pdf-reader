class CreateCoverPrints < ActiveRecord::Migration[5.0]
  def change
    create_table :cover_prints do |t|
      t.string :first_filter
      t.string :second_filter
      t.references :bank, foreign_key: true
      t.references :meta_print, foreign_key: true

      t.timestamps
    end

    add_index :cover_prints, [:first_filter, :second_filter, :meta_print_id], unique: true, name: "cover_filters_index"
  end
end

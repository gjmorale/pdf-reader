class CreateMetaPrints < ActiveRecord::Migration[5.0]
  def change
    create_table :meta_prints do |t|
      t.string :last_ref
      t.string :creator
      t.string :producer
      t.references :bank, foreign_key: true

      t.timestamps
    end

    add_index :meta_prints, [:creator, :producer], unique: true
  end
end

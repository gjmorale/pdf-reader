class CreateCheckmovs < ActiveRecord::Migration[5.0]
  def change
    create_table :checkmovs do |t|
      t.string :path
      t.references :society, foreign_key: true

      t.timestamps
    end
  end
end

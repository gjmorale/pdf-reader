class CreateSourcePaths < ActiveRecord::Migration[5.0]
  def change
    create_table :source_paths do |t|
      t.string :path
      t.references :tax, foreign_key: true

      t.timestamps
    end
    add_index :source_paths, :path, unique: true
  end
end

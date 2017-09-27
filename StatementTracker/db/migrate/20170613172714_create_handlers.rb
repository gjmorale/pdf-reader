class CreateHandlers < ActiveRecord::Migration[5.0]
  def change
    create_table :handlers do |t|
      t.string :short_name
      t.string :repo_path
      t.string :local_path

      t.timestamps
    end
    add_index :handlers, :short_name, unique: true
  end
end

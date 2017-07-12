class CreateHandlers < ActiveRecord::Migration[5.0]
  def change
    create_table :handlers do |t|
      t.string :name
      t.string :short_name
      t.string :repo_path
      t.string :local_path

      t.timestamps
    end
  end
end

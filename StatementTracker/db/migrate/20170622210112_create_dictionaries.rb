class CreateDictionaries < ActiveRecord::Migration[5.0]
  def change
    create_table :dictionaries do |t|
      t.text :identifier
      t.belongs_to :target, polymorphic: true

      t.timestamps
    end
    add_index :dictionaries, :identifier
  end
end

class CreateDictionaryElements < ActiveRecord::Migration[5.0]
  def change
    create_table :dictionary_elements do |t|
      t.belongs_to :element, polymorphic: true
      t.belongs_to :dictionary, foreign_key: true

      t.timestamps
    end
  end
end

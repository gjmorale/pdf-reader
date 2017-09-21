class CreateSynonyms < ActiveRecord::Migration[5.0]
  def change
    create_table :synonyms do |t|
      t.references :listable, polymorphic: true
      t.string :label

      t.timestamps
    end

    add_index :synonyms, [:listable_type, :label], unique: true
  end
end

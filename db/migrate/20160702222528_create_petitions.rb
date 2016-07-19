class CreatePetitions < ActiveRecord::Migration
  def change
    create_table :petitions do |t|
      t.string :name
      t.text :content
      t.integer :creator_id

      t.timestamps null: false
    end
  end
end

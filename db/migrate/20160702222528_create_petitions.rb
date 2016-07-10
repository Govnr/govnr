class CreatePetitions < ActiveRecord::Migration
  def change
    create_table :petitions do |t|
      t.string :title
      t.text :text
      t.integer :creator_id
      t.integer :votes

      t.timestamps null: false
    end
  end
end

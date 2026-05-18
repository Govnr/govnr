class CreatePetitions < ActiveRecord::Migration
  def change
    create_table :petitions do |t|
      t.string :name
      t.text :content
      t.integer :creator_id
      t.integer :group_id
      t.datetime :expires_at
      t.timestamps null: false
    end
  end
end

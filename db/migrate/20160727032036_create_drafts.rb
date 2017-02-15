class CreateDrafts < ActiveRecord::Migration
  def change
    create_table :drafts do |t|
      t.string :name
      t.text :content
      t.integer :motion_id
      t.integer :updater_id
      t.integer :creator_id
      t.integer :statute_id
      t.integer :group_id
      t.timestamps null: false
    end
  end
end

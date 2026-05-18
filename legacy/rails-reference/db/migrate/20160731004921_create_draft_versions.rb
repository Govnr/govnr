class CreateDraftVersions < ActiveRecord::Migration
  def change
    create_table :draft_versions do |t|
      t.string :name
      t.text :content
      t.integer :draft_id
      t.integer :updater_id
      t.integer :number
      t.timestamps null: false
    end
  end
end

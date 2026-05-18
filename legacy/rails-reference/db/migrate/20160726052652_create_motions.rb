class CreateMotions < ActiveRecord::Migration
  def change
    create_table :motions do |t|
      t.belongs_to :petition, index: true
      t.string :name
      t.text :content
      t.integer :group_id
      t.datetime :voting_starts_at
      t.datetime :voting_ends_at
      t.timestamps null: false
    end
  end
end

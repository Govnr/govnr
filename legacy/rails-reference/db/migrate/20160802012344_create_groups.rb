class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.text :content
      t.string :slug
      t.boolean :private
      t.integer :user_id
      t.timestamps null: false
    end
    add_index :groups, :user_id
    add_index :groups, :slug
  end
end

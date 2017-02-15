class CreateStatutes < ActiveRecord::Migration
  def change
    create_table :statutes do |t|
      t.string :name
      t.text :content
      t.integer :group_id
      t.timestamps null: false
    end
  end
end

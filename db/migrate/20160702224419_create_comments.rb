class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content
      t.integer :user_id
      t.integer :rating
      t.integer :upvotes
      t.integer :downvotes
      t.integer :reported
      t.integer :reporter_id
      t.string :report_reason
      t.string :report_comment
      t.boolean :hidden
      t.integer :commentable_id
      t.string :commentable_type
      t.string :ancestry

      t.timestamps null: false
    end
    add_index :comments, :ancestry
  end
end

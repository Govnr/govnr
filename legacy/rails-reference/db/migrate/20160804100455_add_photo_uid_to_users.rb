class AddPhotoUidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :photo_uid, :string
  end
end

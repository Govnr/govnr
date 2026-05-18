class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.time :duration
      t.timestamps null: false
    end
  end
end

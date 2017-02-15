class CreateGroupSettings < ActiveRecord::Migration
  def change
    create_table :group_settings do |t|
      t.integer :group_id
      t.string :logo_uid
      t.decimal :petitions_required_support_percent
      t.decimal :petitions_expiry_time
      t.string :petitions_expiry_time_unit
      t.decimal :motions_delay_before_voting
      t.string :motions_delay_before_voting_unit
      t.decimal :motions_voting_duration
      t.string :motions_voting_duration_unit
      t.decimal :motions_required_majority_percent
      t.timestamps null: false
    end

    add_index :group_settings, :group_id
  end
end
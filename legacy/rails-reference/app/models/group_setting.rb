class GroupSetting < ActiveRecord::Base
	belongs_to :group
	after_initialize :set_defaults
	extend Dragonfly::Model
	include Avatarable
	dragonfly_accessor :logo

	def avatar_text
        group.name.chr
    end

	def set_defaults
		petitions_required_support_percent = 10
		petitions_expiry_time = 28
		petitions_expiry_time_unit = 'Days'
		motions_delay_before_voting = 14
		motions_delay_before_voting_unit = 'Days'
		motions_voting_duration = 5
		motions_voting_duration_unit = 'Days'
		motions_required_majority_percent = 51.1
	end
end

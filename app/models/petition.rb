class Petition < ActiveRecord::Base
	belongs_to :user
	has_many :comments
	has_many :users
	acts_as_taggable
end

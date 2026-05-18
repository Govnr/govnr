class Group < ActiveRecord::Base
	extend FriendlyId
  	friendly_id :name, use: :slugged
  	has_one :group_setting
  	before_create :build_default_group_setting
	has_many :group_memberships
	has_many :users, through: :group_memberships
	has_many :petitions
	has_many :motions
	has_many :drafts
	has_many :statutes
	validates :name, uniqueness: true
	validates_length_of :name, :maximum => 50
	validates_length_of :content, :maximum => 400
	def to_param
    "#{slug}".parameterize
  	end

  	searchable do
	    text :name
	end

	filterrific(
	  default_filter_params: { },
	  available_filters: [
	    :search_query
	  ]
	)

	scope :search_query, lambda { |query|
	  # Searches the students table on the 'first_name' and 'last_name' columns.
	  # Matches using LIKE, automatically appends '%' to each term.
	  # LIKE is case INsensitive with MySQL, however it is case
	  # sensitive with PostGreSQL. To make it work in both worlds,
	  # we downcase everything.
	  return nil  if query.blank?

	  # condition query, parse into individual keywords
	  terms = query.downcase.split(/\s+/)

	  # replace "*" with "%" for wildcard searches,
	  # append '%', remove duplicate '%'s
	  terms = terms.map { |e|
	    (e.gsub('*', '%') + '%').gsub(/%+/, '%')
	  }
	  # configure number of OR conditions for provision
	  # of interpolation arguments. Adjust this if you
	  # change the number of OR conditions.
	  num_or_conds = 1
	  where(
	    terms.map { |term|
	      "(LOWER(groups.name) LIKE ?)"
	    }.join(' AND '),
	    *terms.map { |e| [e] * num_or_conds }.flatten
	  )
	}

private
	def build_default_group_setting
	   build_group_setting
	   true # Always return true in callbacks as the normal 'continue' state
       # Assumes that the default_profile can **always** be created.
       # or
       # Check the validation of the profile. If it is not valid, then
       # return false from the callback. Best to use a before_validation 
       # if doing this. View code should check the errors of the child.
       # Or add the child's errors to the User model's error array of the :base
       # error item
	end
end

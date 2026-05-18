class Motion < ActiveRecord::Base
	belongs_to :petition
	belongs_to :group
	has_many :comments, :as => :commentable, :dependent => :destroy
	has_one :draft
	has_many :polls, :dependent => :destroy
	acts_as_taggable
	acts_as_votable
	include PublicActivity::Model
	PublicActivity.set_controller(MotionsController)
  	tracked except: [:update, :create, :new], owner: Proc.new{ |controller, model| controller.current_user||nil }

	def voteyespercent
	  @voteyes = get_upvotes.size
	  @votes = votes_for.size
	  if (@votes > 0)
	  	return  @voteyes / @votes * 100
	  else
	  	return 0
	  end
	end

	def votenopercent
	  @voteno = get_downvotes.size
	  @votes = votes_for.size
	  if (@votes > 0)
	  	return @voteno / @votes * 100
	  else
	  	return 0
	  end
	end

	def self.vote_ended(group_id, motion_id)
	  @group = Group.find(group_id)
  	  @motion = @group.motions.find(motion_id)
  	  if @motion.voteyespercent >= 51 #Settings.motions.required_majority_percent
  	  	#petition passes to motion
  	  	@draft =  @group.drafts.new(name: @motion.name, content: @motion.content, motion_id: @motion.id)
  	  	@draft.tag_list = @motion.tag_list
  	  	@draft.save
  	  end
  	end

  	# def build_draft
  	# 	create_draft
  	# end

 	searchable do
	    text :name, :content
	    time    :created_at
	    time    :voting_ends_at
	end

	filterrific(
	  default_filter_params: { sorted_by: 'created_at_desc' },
	  available_filters: [
	    :sorted_by,
	    :search_query,
	    :tagged_with,
	    :with_created_at_gte
	  ]
	)

	scope :recent_day, -> { where("created_at > ?", Time.now-1.days) }
	scope :recent_week, -> { where("created_at > ?", Time.now-7.days) }
	scope :recent_month, -> { where("created_at > ?", Time.now-1.month) }
	scope :recent_year, -> { where("created_at > ?", Time.now-1.years) }

	scope :search_query, lambda { |query|
	  return nil  if query.blank?
	  terms = query.downcase.split(/\s+/)
	  terms = terms.map { |e|
	    (e.gsub('*', '%') + '%').gsub(/%+/, '%')
	  }
	  num_or_conds = 1
	  where(
	    terms.map { |term|
	      "(LOWER(motions.name) LIKE ?)"
	    }.join(' AND '),
	    *terms.map { |e| [e] * num_or_conds }.flatten
	  )
	}
	  scope :with_created_at_gte, lambda { |reference_time|
	  	where('motions.created_at >= ?', reference_time)
	  }

	  scope :sorted_by, lambda { |sort_option|
	  direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
	  case sort_option.to_s
	  when /^created_at_/
	    order("motions.created_at #{ direction }")
	  when /^name_/
	    order("LOWER(motions.name) #{ direction }")
	  else
	    raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
	  end
	}

	def self.options_for_sorted_by
    [
      ['Name (a-z)', 'name_asc'],
      ['Creation date (newest first)', 'created_at_desc'],
      ['Creation date (oldest first)', 'created_at_asc'],
    ]
	end

end

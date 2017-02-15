class Draft < ActiveRecord::Base
	belongs_to :group
    belongs_to :creator, class_name: 'User'
    belongs_to :updater, class_name: 'User'

    has_many :versions, -> { order('id DESC') }, class_name: 'DraftVersion', :dependent => :destroy

    # if Irwi.config.page_attachment_class_name
    #   has_many :attachments, class_name: Irwi.config.page_attachment_class_name, foreign_key: Irwi.config.page_version_foreign_key
    # end

    before_save { |record| record.content = '' if record.content.nil? }
    after_save :create_new_version
	belongs_to :motion
	has_many :comments, :as => :commentable, :dependent => :destroy
	acts_as_taggable
	acts_as_votable
	include PublicActivity::Model
  	tracked except: [:new,:create,:update]

  	searchable do
	    text :name
	    # text :comments do
	    #   comments.map { |comment| comment.content }
	    # end
	    time    :created_at

	    # string  :sort_title do
	    #   title.downcase.gsub(/^(an?|the)/, '')
	    # end
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
	      "(LOWER(drafts.name) LIKE ?)"
	    }.join(' AND '),
	    *terms.map { |e| [e] * num_or_conds }.flatten
	  )
	}
	  scope :with_created_at_gte, lambda { |reference_time|
	  	where('drafts.created_at >= ?', reference_time)
	  }

	  scope :sorted_by, lambda { |sort_option|
	  # extract the sort direction from the param value.
	  direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
	  case sort_option.to_s
	  when /^created_at_/
	    # Simple sort on the created_at column.
	    # Make sure to include the table name to avoid ambiguous column names.
	    # Joining on other tables is quite common in Filterrific, and almost
	    # every ActiveRecord table has a 'created_at' column.
	    order("drafts.created_at #{ direction }")
	  when /^name_/
	    # Simple sort on the name colums
	    order("LOWER(drafts.name) #{ direction }")
	  else
	    raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
	  end
	}

	def self.options_for_sorted_by
    [
      ['Name (a-z)', 'name_asc'],
      ['Newest first', 'created_at_desc'],
      ['Oldest first', 'created_at_asc'],
    ]
	end

		  # Retrieve number of last version
	  def last_version_number
	    last = versions.first
	    last ? last.number : 0
	  end

	  protected

	  def create_new_version
	    n = last_version_number
	    v = versions.build
	    v.attributes = attributes.slice(*(v.attribute_names - ['id']))
	    v.number = n + 1
	    v.save!
	  end


end

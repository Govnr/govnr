class Poll < ActiveRecord::Base
	belongs_to :motion
	acts_as_votable

	def voteyespercent
	  @voteyes = self.get_upvotes.size
	  @votes = self.votes_for.size
	  if (@votes > 0)
	  	return  @voteyes / @votes * 100
	  end
	end

	def votenopercent
	  @voteno = self.get_downvotes.size
	  @votes = self.votes_for.size
	  if (@votes > 0)
	  	return @voteno / @votes * 100
	  end
	end

end

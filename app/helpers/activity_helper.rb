 module ActivityHelper
	def activity_for activity
		render partial: 'public_activity/activity', :locals => {:activity => activity, :panel_class => @panel_class, :panel_icon => @panel_icon, :past_participle => @past_participle, :definite_article => @definite_article, :object => @object, :body_content => @body_content, :truncate_length => @truncate_length}
	end
end
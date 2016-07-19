module CommentsHelper
	def nested_comments(comments)
	 comments.map do |comment, sub_comments|
	   content_tag(:div, render(comment), :class => "comment")
	 end.join.html_safe
	end
end

module ApplicationHelper
	def gravatar_for(user, size = 30, title = user.name)
	  image_tag gravatar_image_url(user.email, size: size), title: title, class: 'img-rounded'
	end

	def get_recent_conversations
		@conversations = current_user.mailbox.inbox.limit(5) if current_user.present?
	end
end

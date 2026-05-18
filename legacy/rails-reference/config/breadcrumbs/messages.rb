crumb :conversations do
  link "Messages", conversations_path
  parent :dashboard
end

crumb :conversation do |conversation|
  link conversation.subject.truncate(100), conversation_path(conversation)
  parent :conversations
end

crumb :createconversation do |conversation|
  link "Create", new_message_path
  parent :conversations
end
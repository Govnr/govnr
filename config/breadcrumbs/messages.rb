crumb :root do
  link "Dashboard", root_path
end

crumb :conversations do
  link "Messages", conversations_path
end

crumb :conversation do |conversation|
  link converation.id, conversation_path(conversation)
  parent :messages
end

crumb :createconversation do |conversation|
  link "Create", new_message_path
  parent :conversations
end
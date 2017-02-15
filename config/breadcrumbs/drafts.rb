crumb :drafts do
  link "Drafts", drafts_path
end

crumb :draft do |draft|
  link draft.id, draft_path(draft)
  parent :drafts
end
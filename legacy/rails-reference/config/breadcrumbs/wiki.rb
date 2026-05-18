crumb :wiki do
  link "Wiki", drafts_path
end

crumb :wiki_page do |wiki_page|
  link wiki_page.title, wiki_page_path(@page)
  parent :wiki
end

crumb :wiki_page_history do |wiki_page_history|
  link 'History', wiki_page_history_path(@page)
  parent :wiki_page, wiki_page_history
end

crumb :wiki_page_edit do |wiki_page|
  link 'Edit', wiki_page_edit_path(@page)
  parent :wiki_page, wiki_page
end

crumb :wiki_page_new do |wiki_page|
  link "New", new_wiki_page_path
  parent :wiki
end
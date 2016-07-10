crumb :root do
  link "Dashboard", root_path
end

crumb :petitions do
  link "Petitions", petitions_path
end

crumb :petition do |petition|
  link petition.id, petition_path(petition)
  parent :petitions
end

crumb :createpetition do |petition|
  link "Create", new_petition_path
  parent :petitions
end



crumb :petitions do
	if params[:group_id].present?
		link "Petitions", group_petitions_path(group_id:params[:group_id])

	else
		link "Petitions", petitions_path
	end
  parent :group
end

crumb :petitionsdata do
  link "Data", data_group_petitions_path
  parent :petitions
end


crumb :petition do |petition|
  link petition.id, group_petitions_path(group_id:params[:group_id], id: petition.id)
  parent :petitions
end

crumb :createpetition do |petition|
  link "New", new_group_petition_path
  parent :petitions
end

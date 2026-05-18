crumb :group do |group|
	if group.present?
		link group.name, group_path(group.slug)
	elsif params[:group_id].present?
		link Group.friendly.find(params[:group_id]).name, group_path(Group.friendly.find(params[:group_id]).slug)
	elsif current_group.present?
  		link current_group.name, group_path(current_group.slug)
  	else
  		link 'Group', groups_path
  	end
end

crumb :findgroup do
	link 'Find Group', find_group_path()
end

crumb :newgroup do
	link 'New Group', new_group_path()
end

crumb :settings do
	link 'Settings', settings_group_path(id: params[:id])
	parent :group
end
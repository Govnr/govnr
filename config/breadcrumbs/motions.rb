crumb :motions do
  if params[:group_id].present?
		link "Motions", group_motions_path(group_id:params[:group_id])
  else
			link "Motions", motions_path
  end
  parent :group
end

crumb :motionsdata do
  link "Data", data_group_motions_path
end


crumb :motion do |motion|
  link motion.id, group_motion_path(group_id:params[:group_id],id: motion.id)
  parent :motions
end

crumb :createmotion do |motion|
  link "Create", new_motion_path
  parent :motions
end
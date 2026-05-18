crumb :dashboard do
  link 'Dashboard', root_path
  parent :root
end

crumb :activity do
  link 'Activity', activity_path
  parent :dashboard
end


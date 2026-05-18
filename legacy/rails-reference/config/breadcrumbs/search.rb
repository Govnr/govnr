crumb :search do
  link 'Search', search_path
  parent :group
end

crumb :searchresults do
  link '"'+params[:q]+'"', search_path
  parent :search
end
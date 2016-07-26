crumb :users do
  link "Users", users_path
end

crumb :user do |user|
  link user.name, user_path(user.id)
  parent :users
end


crumb :following do
  link "Following", following_user_path(current_user.id)
  parent :users
end
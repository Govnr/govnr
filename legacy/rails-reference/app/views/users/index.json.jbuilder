json.array!(@users) do |user|
  json.extract! user, :id, :email, :first_name, :last_name, :address, :postcode, :encrypted_password, :salt, :roles
  json.url user_url(user, format: :json)
end

json.array!(@statutes) do |statute|
  json.extract! statute, :id, :name, :content, :motion_id
  json.url statute_url(statute, format: :json)
end

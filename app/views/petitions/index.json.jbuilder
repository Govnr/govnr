json.array!(@petitions) do |petition|
  json.extract! petition, :id, :title, :text, :creator_id
  json.url petition_url(petition, format: :json)
end

json.array!(@motions) do |motion|
  json.extract! motion, :id, :name, :content
  json.url motion_url(motion, format: :json)
end

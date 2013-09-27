json.(@show, :created_at, :updated_at, :live, :id, :name, :description)
json.episodes @show.episodes do |json, episode|
  json_partial! json, 'episodes/show', episode: episode
end

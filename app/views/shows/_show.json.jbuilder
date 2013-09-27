json.(show, :created_at, :updated_at, :id, :title, :description, :subdomain)
json.episodes show.episodes do |json, episode|
  json_partial! json, 'episodes/show',  episode: episode
end

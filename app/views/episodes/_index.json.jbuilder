json.array! episodes do |json, episode|
  json_partial! json, 'episodes/show', episode: episode
end

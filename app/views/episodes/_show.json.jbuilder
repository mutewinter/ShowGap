json.(episode, :title, :slug, :record_date, :state, :id)
json.discussions episode.discussions do |json, discussion|
  json_partial! json, 'discussions/show', discussion: discussion
end

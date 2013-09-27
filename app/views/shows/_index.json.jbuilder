json.array! shows do |json, show|
  json_partial! json, 'shows/show', show: show 
end

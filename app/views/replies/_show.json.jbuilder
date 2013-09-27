json.(reply, :id, :title, :text, :reply_state, :reply_type, :plusminus,
      :created_at)
if current_user
  json.voted_for current_user.voted_for? reply
  json.voted_against current_user.voted_against? reply
end
if reply.author
  json.author do |json|
    json_partial! json, 'users/show', user: reply.author
  end
end

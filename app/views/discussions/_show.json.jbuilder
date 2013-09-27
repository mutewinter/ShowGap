json.(discussion,
      :id, :title, :body, :discussion_type, :reply_name,
      :allows_url_replies, :allows_text_replies,
      :voting_open, :replies_open, :unique_replies,
      :created_at
     )

# Author
if discussion.author
  json.author do |json|
    json_partial! json, 'users/show', user: discussion.author
  end
end

# Replies
json.replies discussion.replies do |json, reply|
  json_partial! json, 'replies/show', reply: reply
end

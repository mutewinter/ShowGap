Fabricator(:reply) do
  title { Faker::HipsterIpsum.sentence.titlecase  }
  text { Faker::Lorem.sentence }
  discussion
end

# Create all the state variations for an reply.
#   e.g. Fabricate(:suggested) makes a Reply with the reply_state
#     set to suggested
Reply.reply_states.keys.map(&:to_s).each do |reply_state|
  Fabricator(reply_state.to_sym, from: :reply) do
    reply_state { reply_state }
  end
end

# Generates a reply that contains a text link.
# TODO set the class of this to link once that's implemented in the model
Fabricator(:link, from: :reply) do
  text { Faker::Internet.http_url }
end

Fabricator(:discussion) do
  title { Faker::HipsterIpsum.sentence.titlecase  }
  body { Faker::HTMLIpsum.body }
  discussion_type { Discussion.discussion_types.keys.map(&:to_s).sample }
  episode
end

# Create all the discussion_type variations for an episode.
#   e.g. Fabricate(:accept_one) makes a Discussion with discussion_type set to
#   accept_one.
Discussion.discussion_types.keys.map(&:to_s).each do |discussion_type|
  Fabricator(discussion_type.to_sym, from: :discussion) do
    discussion_type { discussion_type }
  end
end

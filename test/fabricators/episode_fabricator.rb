Fabricator(:episode) do
  slug { sequence(:email) { |i| i.to_s } }
  state { Episode.states.keys.map(&:to_s).sample }
  show
end

# Create all the state variations for an episode.
#   e.g. Fabricate(:public) makes a Episode with state set to public.
Episode.states.keys.map(&:to_s).each do |state|
  Fabricator(state.to_sym, from: :episode) do
    state { state }
  end
end

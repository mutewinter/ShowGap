class Showgap.Collections.Replies extends Backbone.Collection
  url: '/api/replies'
  model: Showgap.Models.Reply

  # Internal: Default comparitor for a reply collection is the vote total. The
  # minus reverses the sort.
  #
  # Returns the plusminus value for a reply.
  comparator: (reply) -> -reply.get('plusminus')

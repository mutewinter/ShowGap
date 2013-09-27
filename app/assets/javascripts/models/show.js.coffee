class Showgap.Models.Show extends Backbone.RelationalModel
  relations: [
    type: Backbone.HasMany
    key: 'episodes'
    relatedModel: 'Showgap.Models.Episode'
    collectionType: 'Showgap.Collections.Episodes'
    reverseRelation:
      key: 'show'
      includeInJSON: 'id'
      keyDestination: 'show_id'
  ]

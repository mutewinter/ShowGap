class Vote < ActiveRecord::Base

  scope :for_voter, lambda { |*args| where(["voter_id = ? AND voter_type = ?", args.first.id, args.first.class.base_class.name]) }
  scope :for_voteable, lambda { |*args| where(["voteable_id = ? AND voteable_type = ?", args.first.id, args.first.class.base_class.name]) }
  scope :recent, lambda { |*args| where(["created_at > ?", (args.first || 2.weeks.ago)]) }
  scope :descending, order("created_at DESC")

  belongs_to :voteable, polymorphic: true
  belongs_to :voter, polymorphic: true

  attr_accessible :vote, :voter, :voteable

  # Comment out the line below to allow multiple votes per user.
  validates :voteable_id,
    uniqueness: {
      scope: [:voteable_type, :voter_type, :voter_id],
      message: "Only one vote per user."
    }
  validate :one_vote_for_poll

  def one_vote_for_poll
    # Only check if this is a reply and the discussion is a poll.
    if voteable.instance_of?(Reply) and voteable.discussion.poll?
      discussion = voteable.discussion

      # Check if the user has voted on any other replies.
      if discussion.has_user_voted(voter)
        errors.add(:vote, 'only once per poll.')
      end
    end
  end

end

# == Schema Information
#
# Table name: votes
#
#  id            :integer          not null, primary key
#  vote          :boolean          default(FALSE)
#  voteable_id   :integer          not null
#  voteable_type :string(255)      not null
#  voter_id      :integer
#  voter_type    :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#


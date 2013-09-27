class Discussion < ActiveRecord::Base
  attr_accessible :title, :body, :reply_name,
    # Assocations
    :episode,
    # Enums
    :discussion_type,
    # Booleans
    :allows_url_replies, :allows_text_replies,
    :voting_open, :replies_open, :unique_replies

  # Associations
  has_many :replies, dependent: :destroy
  belongs_to :author, class_name: 'User'
  belongs_to :episode
  # So we can access the votes on this disucssion when it's a Poll to validate
  # the user only votes once. Validation is in vote model.
  has_many :votes, through: :replies

  # Validations
  validates :title, presence: true
  validates :reply_name, presence: true

  # Enumerations
  # Note: Default values for all enumerations is 10, which means the first
  #       value will be the default in all below enums.
  # Warning: Hash symbols for enums must be unique across _all enums_ or
  # methods like discussion.accept_one? won't work.

  as_enum :discussion_type, question: 10, poll: 20

  def has_user_voted(user)
    votes.where(voter_id: user.id).present?
  end
end

# == Schema Information
#
# Table name: discussions
#
#  id                  :integer          not null, primary key
#  title               :string(255)
#  body                :text
#  episode_id          :integer
#  discussion_type_cd  :integer          default(10)
#  allows_url_replies  :boolean          default(TRUE)
#  allows_text_replies :boolean          default(TRUE)
#  voting_open         :boolean          default(TRUE)
#  replies_open        :boolean          default(TRUE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  reply_name          :string(255)      default("Reply")
#  author_id           :integer
#  unique_replies      :boolean          default(FALSE)
#


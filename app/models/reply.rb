class Reply < ActiveRecord::Base
  acts_as_voteable

  attr_accessible :title, :text, :reply_type,
    # Assocations
    :author, :discussion,
    # Enums
    :reply_state

  # Validations
  validates_presence_of :discussion
  validates :title, presence: {
    unless: Proc.new { |a| a.text.present? },
    message: "Both the Title and the Text of your Reply can't be blank."
  }
  validates :title, uniqueness: {
    scope: :discussion_id,
    if: Proc.new { |a| a.discussion.unique_replies },
    unless: Proc.new { |a| a.title.blank? },
    message: 'A reply with a title like yours has already been submitted.'
  }
  validates :text, uniqueness: {
    scope: :discussion_id,
    if: Proc.new { |a| a.discussion.unique_replies },
    unless: Proc.new { |a| a.text.blank? },
    message: 'A reply with content like yours has already been submitted.'
  }

  # Associations
  belongs_to :discussion
  belongs_to :author, class_name: 'User'

  as_enum :reply_state, suggested: 10, accepted: 20, created: 30
  as_enum :reply_type, title: 10, url: 20, text: 30
end

# == Schema Information
#
# Table name: replies
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  text           :string(255)
#  reply_state_cd :integer          default(10)
#  author_id      :integer
#  discussion_id  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  reply_type_cd  :integer          default(10)
#


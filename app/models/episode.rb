class Episode < ActiveRecord::Base
  attr_accessible :title, :slug, :record_date,
    # Assocations
    :show,
    # Enums
    :state

  # Assocations
  belongs_to :show
  has_many :discussions, dependent: :destroy

  # Validations
  validates :show, presence: true

  # Determines how the episode appears in the browser.
  as_enum :state, public: 10, hidden: 20, live: 30
end

# == Schema Information
#
# Table name: episodes
#
#  id          :integer          not null, primary key
#  slug        :string(255)
#  state_cd    :integer          default(10)
#  show_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  title       :string(255)
#  record_date :datetime
#


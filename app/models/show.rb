class Show < ActiveRecord::Base
  # Security
  attr_accessible :title, :description, :subdomain

  # Associations
  has_many :episodes, dependent: :destroy

  # Validations
  validates :title, :subdomain, presence: true
  validates :subdomain, uniqueness: true
end

# == Schema Information
#
# Table name: shows
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  subdomain   :string(255)
#


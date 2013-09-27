class User < ActiveRecord::Base
  ROLES = %w[admin host listener]

  # Make this model able to cast votes
  acts_as_voter

  attr_accessible :provider, :uid, :name, :nickname, :description, :image,
      :website, :location, :role

  validates_presence_of :uid

  has_many :discussions
  has_many :replies

  # Public: Finds or updates a user from an omniauth hash.
  #
  # auth_hash - A Hashie Omniauth hash retreived from the
  #   request.env['omniauth.auth']
  #
  # Examples
  #
  #   find_or_create_from_auth_hash({
  #     provider: twitter
  #     uid: '15398907'
  #     info:
  #       nickname: mutewinter
  #       name: Jeremy Mack
  #       location: ''
  #       image: http://a0.twimg.com/mutewinter_normal.jpeg
  #       description: I am a Viking.
  #       urls:
  #         Website: http://pileofturtles.com
  #         Twitter: http://twitter.com/mutewinter
  #   })
  #
  # Returns/Raises the user model.
  def self.find_or_create_from_auth_hash(auth_hash)
    case auth_hash.provider
    when 'twitter'
      user = User.find_or_create_by_uid(auth_hash.uid)

      unless user.role?
        user.role = 'listener'
        user.save
      end

      return false unless user.valid?

      info = auth_hash.info

      user.update_attributes(
        provider: auth_hash.provider,
        name: info.name,
        nickname: info.nickname,
        image: info.image,
        description: info.description,
        website: info.urls ? info.urls.website : '' # Twitter-specific
      )
      return user
    else
      # Invalid provider
      logger.error "Invalid Auth Provider found, #{auth_hash.provider}"
      return false
    end

  end

  def admin?
    role == 'admin'
  end

  def host?
    role == 'host'
  end

  def listener?
    role == 'listener'
  end

end

# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  provider    :string(255)
#  uid         :string(255)
#  name        :string(255)
#  nickname    :string(255)
#  description :string(255)
#  image       :string(255)
#  website     :string(255)
#  location    :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  role        :string(255)
#


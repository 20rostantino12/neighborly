class Authorization < ActiveRecord::Base
  attr_accessible :oauth_provider, :oauth_provider_id, :uid, :user_id, :user, :access_token, :access_token_secret, :access_token_expires_at

  belongs_to :user
  belongs_to :oauth_provider

  validates_presence_of :oauth_provider, :uid

  scope :from_hash, ->(hash){
    joins(:oauth_provider).where("oauth_providers.name = :name AND uid = :uid", { name: hash['provider'], uid: hash['uid'] })
  }

  scope :from_hash_without_uid, ->(hash){
    joins(:oauth_provider).where("oauth_providers.name = :name", { name: hash['provider'] }).joins(:user).where('users.email = :email', { email: hash['info']['email'] })
  }
end

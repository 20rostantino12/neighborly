class Authorization < ActiveRecord::Base
  attr_accessible :oauth_provider, :oauth_provider_id, :uid, :user_id, :user, :access_token, :access_token_secret, :access_token_expires_at

  belongs_to :user
  belongs_to :oauth_provider

  validates_presence_of :oauth_provider, :uid
end

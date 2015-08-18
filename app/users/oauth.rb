module Oauth
  class Base
    attr_accessor :profile
  end
end

require_relative 'oauth/facebook'
require_relative 'oauth/google'
require_relative 'oauth/twitter'
require_relative 'oauth_profile'
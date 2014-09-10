module Venmo
  class Client include Singleton
    attr_accessor :client_id, :secret, :scope, :response_type
    @@VENMO_BASE_URL = 'https://api.venmo.com/v1/'
    def initialize (options = {})
      if response_type != 'code' || response_type != 'token'
        raise 'Response type muse be "code" or "token" for server-side and client-side flow respectively'
      elsif scope.class.name != 'Array'
        raise 'Scope must be an array'
      end
    end
  end
end
require 'net/http'
require 'venmo/helper'
require 'venmo/user'

module VenmoAPI
  class Client
    attr_accessor :client_id, :secret, :scope, :response_type

    def initialize (options = {})
      yield(self) if block_given?
      validate_credentials
    end

    def auth_link
      return VenmoAPI::Helper::VENMO_BASE_URL + 'oauth/authorize?client_id=' + client_id.to_s + '&scope=' + scope.join(' ') + '&response_type=' + response_type
    end

    def authenticate (key)
      if self.response_type == 'code'
        uri = URI(VenmoAPI::Helper::VENMO_BASE_URL + 'oauth/access_token')
        res = Net::HTTP.post_form(uri, 'client_id' => self.client_id, 'client_secret' => self.secret, 'code' => key)
        res_data = JSON.parse(res.body)
        puts res_data.inspect
        if res_data['access_token']
          user = User.new(VenmoAPI::Helper::recursive_symbolize_keys!(res_data), self.response_type);
        else
          user = nil;
        end
        return user;
      else
        user = User.new({:access_token => key}, self.response_type)
        return user;
      end
    end

    def credentials
      {
        :client_id => client_id,
        :secret => secret,
        :scope => scope,
        :response_type => response_type
      }
    end

    def get_user(id, access_token)
      uri = URI(VenmoAPI::Helper::VENMO_BASE_URL + 'users/' + id.to_s + '?access_token=' + access_token)
      res = Net::HTTP.get(uri)
      return JSON.parse(res)
    end

    def get_payment (id, access_token)
      uri = URI(VenmoAPI::Helper::VENMO_BASE_URL + 'payments/' + id.to_s + '?access_token=' + access_token)
      res = Net::HTTP.get(uri)
      return JSON.parse(res)
    end

    def get_recent_payments access_token
      uri = URI(VenmoAPI::Helper::VENMO_BASE_URL + 'payments?access_token=' + access_token)
      res = Net::HTTP.get(uri)
      return JSON.parse(res)
    end

    private
    def validate_credentials
      credentials.each do |credential, value|
        if credential == :client_id && !value.is_a?(Fixnum)
          raise "Client ID must be a number"
        elsif credential == :secret && !value.is_a?(String)
          raise "Secret must be a string"
        elsif credential == :scope && !value.is_a?(Array)
          raise "Scope must be an array"
        elsif credential == :response_type && !value.is_a?(String) && (value == 'code' || value == 'token')
          raise "Response Type must be equal to 'code' or 'token'"
        end
      end
    end

  end
end
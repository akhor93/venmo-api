require 'net/http'
require 'venmo/helper'

module VenmoAPI
  class User
    attr_accessor :access_token, :expires_in, :refresh_token, :token_updated, :response_type, :data
    def initialize(obj, response_type)
      puts obj.inspect
      self.access_token = obj[:access_token]
      self.response_type = response_type
      if response_type == 'code'
        self.expires_in = obj[:expires_in]
        self.refresh_token = obj[:refresh_token]
        # self.token_type = obj[:bearer]
        self.token_updated = Time.now
        self.data = obj[:user]
      end
      VenmoAPI::Helper::recursive_symbolize_keys! self.data
      validate_properties response_type
    end

    def update_info
      uri = URI(VenmoAPI::Helper::VENMO_BASE_URL + 'me?access_token=' + self.access_token)
      res = Net::HTTP.get(uri)
      self.data = VenmoAPI::Helper::recursive_symbolize_keys! JSON.parse(res)["data"]
    end

    def get_info(update = true)
      if update
        update_info
      end
      return self.data
    end

    def get_user(id)
      uri = URI(VenmoAPI::Helper::VENMO_BASE_URL + 'users/' + id + '?access_token=' + self.access_token)
      res = Net::HTTP.get(uri)
      return JSON.parse(res)["data"]
    end

    def get_friends (options = {})
      if options[:id]
        url = VenmoAPI::Helper::VENMO_BASE_URL + 'users/' + options[:id] + '/friends?access_token=' + self.access_token
      else
        if self.data[:user][:id]
          url = VenmoAPI::Helper::VENMO_BASE_URL + 'users/' + self.data[:user][:id] + '/friends?access_token=' + self.access_token
        else
          raise "get_friends must be called with an id if there is no id present on the current user"
        end
      end
      url += options[:before] ? "&before=" + options[:before] : ''
      url += options[:after] ? "&after=" + options[:after] : ''
      url += options[:limit] ? "&limit=" + options[:limit] : ''
      res = Net::HTTP.get(URI(url))
      return JSON.parse(res)
    end

    private
    def validate_properties (response_type)
      if !self.access_token
        raise "Missing access token"
      elsif !self.expires_in && response_type == 'code'
        raise "Missing expires_in"
      elsif !self.refresh_token && response_type == 'code'
        raise "Missing refresh token"
      elsif !self.token_updated && response_type == 'code'
        raise "Missing token_updated"
      end
    end
  end
end
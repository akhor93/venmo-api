require 'net/http'
require 'venmo/helper'
require 'venmo/payment'

module VenmoAPI
  class User
    attr_accessor :access_token, :expires_in, :refresh_token, :token_updated, :response_type, :token_type, :data
    def initialize(obj, response_type)
      self.access_token = obj[:access_token]
      self.response_type = response_type
      if response_type == 'code'
        self.expires_in = obj[:expires_in]
        self.refresh_token = obj[:refresh_token]
        self.token_type = obj[:bearer]
        self.token_updated = Time.now
        self.data = obj[:user]
      end
      VenmoAPI::Helper::recursive_symbolize_keys! self.data
      validate_properties response_type
    end

    def update_info
      uri = URI(VenmoAPI::Helper::VENMO_BASE_URL + 'me?access_token=' + self.access_token)
      res = Net::HTTP.get(uri)
      res_data = JSON.parse(res)
      if res_data["data"]
        self.data = VenmoAPI::Helper::recursive_symbolize_keys! res_data["data"]
      end
    end

    def get_info(update = true)
      if update
        update_info
      end
      return self.data
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

    def get_user(id)
      uri = URI(VenmoAPI::Helper::VENMO_BASE_URL + 'users/' + id.to_s + '?access_token=' + self.access_token)
      res = Net::HTTP.get(uri)
      return JSON.parse(res)
    end

    def make_payment (options = {})
      payment = Payment.new(options)
      return payment.send self.access_token
    end

    def get_payment (id)
      uri = URI(VenmoAPI::Helper::VENMO_BASE_URL + 'payments/' + id.to_s + '?access_token=' + self.access_token)
      res = Net::HTTP.get(uri)
      return JSON.parse(res)
    end

    def get_recent_payments
      uri = URI(VenmoAPI::Helper::VENMO_BASE_URL + 'payments?access_token=' + self.access_token)
      res = Net::HTTP.get(uri)
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
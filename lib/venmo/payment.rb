module VenmoAPI
  class Payment
    attr_accessor :data, :phone, :email, :user_id, :note, :amount, :audience, :sent
    def initialize(options = {})
      self.phone = options[:phone]
      self.email = options[:email]
      self.user_id = options[:user_id]
      self.note = options[:note]
      self.amount = options[:amount]
      self.audience = options[:audience] ? options[:audience] : 'friends'
      validate_properties
    end

    def send (access_token)
      uri = URI(VenmoAPI::Helper::VENMO_BASE_URL + 'payments')
      res = Net::HTTP.post_form(uri, 'access_token' => access_token,
                                     'phone' => self.phone,
                                     'email' => self.email,
                                     'user_id' => self.user_id,
                                     'note' => self.note,
                                     'amount' => self.amount,
                                     'audience' => self.audience)
      return VenmoAPI::Helper::recursive_symbolize_keys! JSON.parse(res)
    end

    def self.get_payment
      test = "test"
    end

    private

    def validate_properties
      if options[:user_id] || options[:phone] || options[:email]
        raise "make_payment requires a target. Please provide a user_id, phone, or email in options hash"
      elsif !options[:note]
        raise "make_payment requires a note in options hash"
      elsif !options[:amount]
        raise "make_payment requires an amount in options hash"
      end
    end

  end
end
module VenmoAPI
  class Helper
    VENMO_BASE_URL = 'https://api.venmo.com/v1/'
    def recursive_symbolize_keys! hash
      hash.symbolize_keys!
      hash.values.select{|v| v.is_a? Hash}.each{|h| recursive_symbolize_keys!(h)}
    end
  end
end
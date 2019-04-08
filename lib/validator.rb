class Validator

  class << self

    # Check for integer
    #
    def is_integer?(object)
      return is_numeric?(object) && Float(object) == Integer(object) rescue false
    end

    # Check for numeric
    #
    def is_numeric?(object)
      true if Float(object) rescue false
    end

    # Is alpha number
    #
    def self.is_alphanumeric?(object)
      object =~ /\A[A-Z0-9]+\z/i
    end

    # Is alpha number space
    #
    def self.is_alphanumeric_space?(object)
      object =~ /\A[A-Z0-9\s]+\z/i
    end

    # Is uuid v4
    #
    def self.is_uuid_v4?(object)
      object =~ /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i
    end

    # Is URL
    #
    def self.is_url?(object)
      object =~ /\A#{URI::regexp(['https'])}\z/i
    end

  end

end
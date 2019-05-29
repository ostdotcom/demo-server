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
    def is_alphanumeric?(object)
      object =~ /\A[A-Z0-9]+\z/i
    end

    # Is alpha number space
    #
    def is_alphanumeric_space?(object)
      object =~ /\A[A-Z0-9\s]+\z/i
    end

    # Is alpha number equal to
    #
    def is_alphanumeric_equal?(object)
      object =~ /\A[A-Z0-9=]+\z/i
    end

    # Is alpha space
    #
    def is_alpha_space?(object)
      object =~ /\A[A-Z\s]+\z/i
    end

    # Is uuid v4
    #
    def is_uuid_v4?(object)
      object =~ /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i
    end

    # Is URL
    #
    def is_url?(object)
      object =~ /\A#{URI::regexp(['http', 'https'])}\z/i
    end

    # Is Valid Eth Address
    #
    def is_ethereum_address?(object)
      object =~ /\A0x[a-f0-9]{40}\z/i
    end

    # Is an array
    #
    def is_array?(object)
      object.is_a? Array
    end

  end

end
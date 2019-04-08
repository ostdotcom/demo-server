# frozen_string_literal: true
module GlobalConstant

  class Base

    class << self

      def environment
        Rails.env
      end

    end

  end

end

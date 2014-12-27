module OraUtils
# encoding: UTF-8
#
#
# Define all common mungers available for all types
#
  module Mungers
    #
    # Define some Oracle specific mungers
    #    
    module LeaveSidRestToUppercase
      #
      # This munger extracts the sid from the value and uppercases therest of the value. 
      # The sid remains as it is.
      #
      def unsafe_munge(original_value)
       value, _, sid = original_value.partition('@') 
        "#{value.upcase}@#{sid}"
      end
    end
  end
end

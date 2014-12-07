require 'ora_utils/oracle_access'

module OraUtils
  module TitleParser
    include OracleAccess


    def parse_sid_title
      @@sid_parser ||= lambda { |sid_name| sid_name.nil? ? default_sid : sid_name[0..-2]}
    end

    def parse_name
      @@name_parser ||= lambda { |name|name.include?('/') ? name : "#{default_sid}/#{name}"}
    end


    def map_title_to_sid(*attributes, &proc)
      base_attributes = [:name, parse_name] , [:sid, parse_sid_title]
      all_attributes = base_attributes + attributes
      map_title_to_attributes(*all_attributes, &proc)
    end

    def default_sid
      oratab = OraTab.new
      oratab.default_sid
    rescue
      ''
    end
  end
end




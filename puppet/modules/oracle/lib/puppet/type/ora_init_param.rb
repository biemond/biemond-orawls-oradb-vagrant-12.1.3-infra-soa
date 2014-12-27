require 'pathname'
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent)
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent.parent.parent + 'easy_type' + 'lib')
require 'easy_type'
require 'ora_utils/oracle_access'
require 'ora_utils/title_parser'
require 'ora_utils/ora_tab'

TITLE_PATTERN = /^((.*?\/)?(.*?)(:.*?)?(\@.*?)?)$/

module Puppet
  newtype(:ora_init_param) do
    include EasyType
    include ::OraUtils::OracleAccess

    desc "This resource allows you to manage Oracle parameters."

    set_command(:sql)

    ensurable

    to_get_raw_resources do
      specified_parameters_for(memory) + specified_parameters_for(spfile)
    end

    def apply(command_builder)
      if is_number?(self[:value]) || is_boolean?(self[:value])
        specified_value = self[:value]
      else
        specified_value = "'#{self[:value]}'"
      end
      statement = "alter system set #{parameter_name}=#{specified_value} scope=#{scope}"
      statement+= " sid='#{for_sid}'" if scope == 'SPFILE'
      command_builder.add(statement, :sid => sid)
    end


    on_create do | command_builder |
      apply(command_builder)
    end

    on_modify do | command_builder |
      apply(command_builder)
    end

    on_destroy do | command_builder |
      statement = "alter system reset #{parameter_name} scope=#{scope} sid='#{for_sid}'"
      command_builder.add(statement, :sid => sid)
    end

    parameter :name
    parameter :parameter_name
    parameter :sid
    parameter :scope
    parameter :for_sid

    property  :value

    private

    def is_number?(value)
      (Integer(value) rescue false) && true
    end

    def is_boolean?(value)
      case value
      when 'TRUE','FALSE' ,'true' ,'false' then return true
      end
      !!value == value
    end

    def self.parse_scope
      lambda { |scope| scope[0..-2]}
    end

    def self.parse_for_sid
      lambda { |for_sid| for_sid.nil? ?  '*' : for_sid[1..-1]}
    end

    def self.parse_sid
      lambda { |sid_name| sid_name.nil? ? default_sid : sid_name[1..17]}
    end


    def self.parse_name
      lambda do |name|
        result    = name.scan(TITLE_PATTERN)
        groups    = result[0]
        scope     = parse_scope.call(groups[1]).upcase
        parameter = groups[2]
        for_sid   = parse_for_sid.call(groups[3])
        sid       = parse_sid.call(groups[4])
        if scope == 'MEMORY'
          "#{scope}/#{parameter}@#{sid}"
        else
          "#{scope}/#{parameter}:#{for_sid}@#{sid}"
        end
      end
    end

    map_title_to_attributes(
      [:name, parse_name],
      [:scope, parse_scope], 
      :parameter_name,
      [:for_sid, parse_for_sid],
      [:sid, parse_sid]) { TITLE_PATTERN}


    def self.specified_parameters_for(set)
      set.select{|p| p['DISPLAY_VALUE'] != ''}
    end

    def self.memory
      sql_on_all_sids %{select 'MEMORY' as scope, t.issys_modifiable, t.name, t.value, t.display_value, b.instance_name as for_sid from gv$parameter t, gv$instance b where t.inst_id = b.instance_number and t.issys_modifiable <> 'FALSE'}
    end

    def self.spfile
      sql_on_all_sids %q{select 'SPFILE' as scope, t.isspecified, t.name, t.value, t.display_value, t.sid as for_sid from gv$spparameter t, gv$instance b where t.inst_id = b.instance_number and t.isspecified = 'TRUE'}
    end

    def self.default_sid
      oratab = OraUtils::OraTab.new
      oratab.default_sid
    rescue
      ''
    end


  end
end

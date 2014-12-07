require 'pathname'
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent)
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent.parent.parent + 'easy_type' + 'lib')
require 'easy_type'
require 'ora_utils/oracle_access'
require 'ora_utils/title_parser'

module Puppet
  #
  # Create a new type oracle_user. Oracle user, works in conjunction 
  # with the SqlResource
  #
  newtype(:role) do
    include EasyType
    include ::OraUtils::OracleAccess
    extend ::OraUtils::TitleParser

    desc "This resource allows you to manage a role in an Oracle database."

    set_command(:sql)

    ensurable

    to_get_raw_resources do
      sql_on_all_sids "select * from dba_roles"
    end

    on_create do | command_builder |
      command_builder.add("create role #{role_name}", :sid => sid)
    end

    on_modify do | command_builder |
      command_builder.add("alter role# {role_name}", :sid => sid)
    end

    on_destroy do | command_builder |
      command_builder.add("drop role #{role_name}", :sid => sid)
    end

    map_title_to_sid(:role_name) { /^((.*?\/)?(.*)?)$/}

    parameter :name
    parameter :role_name
    parameter :sid
    property  :password

  end
end



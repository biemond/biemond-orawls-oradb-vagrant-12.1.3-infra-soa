require 'pathname'
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent)
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent.parent.parent + 'easy_type' + 'lib')
require 'easy_type'
require 'ora_utils/oracle_access'
require 'ora_utils/title_parser'
require 'ora_utils/ora_tab'

module Puppet
  #
  # Create a new type oracle_user. Oracle user, works in conjunction 
  # with the SqlResource provider
  #
  newtype(:ora_asm_diskgroup) do
    include EasyType
    include ::OraUtils::OracleAccess
    extend ::OraUtils::TitleParser

    desc %q{
      This resource allows you to manage a user in an Oracle database.
    }

    ensurable

    set_command(:sql)

    to_get_raw_resources do
      oratab = OraUtils::OraTab.new
      sids = oratab.running_asm_sids
      statement = template('puppet:///modules/oracle/diskgroup_index.sql', binding)
      sql_on(sids, statement, :username => 'sysasm', :os_user => 'grid')
    end

    on_create do | command_builder |
      statement = template('puppet:///modules/oracle/diskgroup_create.sql.erb', binding)
      command_builder.add(statement, :sid => sid, :username => 'sysasm', :os_user => 'grid')
    end

    on_modify do | command_builder |
      Puppet.info "No disk groups modified. Function not implemented yet."
      nil
    end

    on_destroy do | command_builder |
      statement = template('puppet:///modules/oracle/diskgroup_destroy.sql.erb', binding)
      command_builder.add(statement, :sid => sid, :username => 'sysasm', :os_user => 'grid')
    end


    map_title_to_sid(:groupname) { /^((@?.*?)?(\@.*?)?)$/}

    parameter :name
    parameter :groupname
    parameter :sid

    parameter :diskgroup_state
    property  :redundancy_type
    property  :au_size
    property  :compat_asm
    property  :compat_rdbms
    property  :failgroups

  end
end

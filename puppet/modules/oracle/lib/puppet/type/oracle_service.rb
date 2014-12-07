require 'pathname'
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent)
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent.parent.parent + 'easy_type' + 'lib')
require 'easy_type'
require 'ora_utils/oracle_access'
require 'ora_utils/title_parser'


module Puppet
  newtype(:oracle_service) do
    include EasyType
    include ::OraUtils::OracleAccess
    extend ::OraUtils::TitleParser

    desc %q{
      This resource allows you to manage a service in an Oracle database.
    }

    ensurable

    set_command(:sql)


    to_get_raw_resources do
      sql_on_all_sids "select name from dba_services"
    end

    on_create do | command_builder |
      sql "exec dbms_service.create_service('#{service_name}', '#{service_name}'); dbms_service.start_service('#{service_name}')", :sid => sid
      new_services = current_services << service_name
      statement = set_services_command(new_services)
      command_builder.add(statement, :sid => sid)
    end

    on_modify do | command_builder |
      fail "It shouldn't be possible to modify a service"
    end

    on_destroy do | command_builder |
      sql  "exec dbms_service.stop_service('#{service_name}'); dbms_service.delete_service('#{service_name}')", :sid => sid
      new_services = current_services.delete_if {|e| e == service_name }
      statement = set_services_command(new_services)
      command_builder.add(statement, :sid => sid)
    end

    map_title_to_sid(:service_name) { /^((.*?\/)?(.*)?)$/}

    parameter :name
    parameter :service_name
    parameter :sid

    private

      def set_services_command(services)
        "alter system set service_names = '#{services.join('\',\'')}' scope=both"
      end

      def current_services
        provider.class.instances.map(&:service_name)
      end

  end
end
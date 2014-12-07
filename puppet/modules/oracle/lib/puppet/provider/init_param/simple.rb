require 'ora_utils/oracle_access'
require 'easy_type'

Puppet::Type.type(:init_param).provide(:simple) do
	include EasyType::Provider
	include ::OraUtils::OracleAccess

  desc "Manage Oracle Instance Parameters in an Oracle Database via regular SQL"

  mk_resource_methods

end


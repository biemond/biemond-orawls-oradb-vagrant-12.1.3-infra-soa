require 'ora_utils/oracle_access'
require 'easy_type'

Puppet::Type.type(:oracle_service).provide(:simple) do
	include EasyType::Provider
	include ::OraUtils::OracleAccess

  desc "Manage Oracle services via regular SQL"

  mk_resource_methods

end


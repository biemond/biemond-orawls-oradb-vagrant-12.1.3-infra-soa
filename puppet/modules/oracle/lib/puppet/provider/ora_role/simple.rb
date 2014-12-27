require 'ora_utils/oracle_access'
require 'easy_type'

Puppet::Type.type(:ora_role).provide(:simple) do
	include EasyType::Provider
	include ::OraUtils::OracleAccess

  desc "Manage an Oracle role in an Oracle Database via regular SQL"

  mk_resource_methods

end


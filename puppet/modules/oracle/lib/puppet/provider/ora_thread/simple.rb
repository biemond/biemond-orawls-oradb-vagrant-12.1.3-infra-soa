require 'easy_type'
require 'ora_utils/oracle_access'

Puppet::Type.type(:ora_thread).provide(:simple) do
  include EasyType::Provider
  include ::OraUtils::OracleAccess

  desc "Manage Oracle users in an Oracle Database via regular SQL"

  mk_resource_methods

end


require 'easy_type'
require 'ora_utils/oracle_access'

Puppet::Type.type(:asm_diskgroup).provide(:simple) do
  include EasyType::Provider
  include ::OraUtils::OracleAccess

  desc "Manage RAC ASM groups in an Oracle Database via regular SQL"


  mk_resource_methods

end


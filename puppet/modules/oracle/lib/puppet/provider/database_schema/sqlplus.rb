require 'ora_utils/oracle_access'
require 'easy_type'

Puppet::Type.type(:database_schema).provide(:sqlplus) do
  include EasyType::Provider
  include ::OraUtils::OracleAccess

  desc "Manage Oracle database schema;s via regular SQL"

  mk_resource_methods

  #
  # Returns the current version of the schema
  #
  def current_version
  end

  #
  # Apply a specific version
  def apply_version(version)
  end

  #
  # Upgrade to a specified version
  #
  def upgrade_to_version(version)
  end

  #
  # Downgrade to a specified version
  #
  def downgrade_to_version(version)
  end

  #
  # Apply a specific version number to the database
  #
  def apply_update(version)
  end

  #
  # Create the initial table to contain the applied version numbers
  #
  def bootstrap
  end

  def update_schema_version(sequence, system, version, module_name)
    sql "insert into schema_version (sequence, system_name, version, module_name, installation_time) values ('#{sequence}', '#{system}', '#{version}', '#{module_name}', sysdate); commit;"

end


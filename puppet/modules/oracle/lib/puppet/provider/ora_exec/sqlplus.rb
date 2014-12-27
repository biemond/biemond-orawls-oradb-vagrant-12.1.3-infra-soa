require 'ora_utils/oracle_access'
require 'easy_type/helpers'
require 'ora_utils/ora_tab'


Puppet::Type.type(:ora_exec).provide(:sqlplus) do
  include OraUtils::OracleAccess
  include EasyType::Helpers
  include EasyType::Template

  mk_resource_methods

  def flush
    statement = resource.to_hash[:statement]
    if is_script?(statement)
      script_name = statement.sub('@','')
      statement = template(script_name, binding)
    end
    sid = sid_from_resource
    output = sql statement, :username => resource.username, :password => resource.password, :sid => sid
    Puppet.debug(output) if resource.logoutput == :true
  end

  private

  def is_script?(statement)
    statement[0] == 64
  end

end

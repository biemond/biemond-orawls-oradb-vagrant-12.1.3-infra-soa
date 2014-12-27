require 'ora_utils/oracle_access'

Puppet::Type.type(:ora_listener).provide(:listener) do
  include OraUtils::OracleAccess

  def self.instances
    []
  end

  def listener( action)
    db_sid = resource.name
    command = "su - oracle -c 'export ORACLE_SID=#{db_sid};export ORAENV_ASK=NO;. oraenv;lsnrctl #{action}'"
    execute command, :failonfail => false, :override_locale => false, :squelch => true
  end

  def start
    listener :start
  end

  def stop
    listener :stop
  end

  def status
    listener :status
    if $CHILD_STATUS.exitstatus == 0
      return :running
    else
      return :stopped
    end
  end
end

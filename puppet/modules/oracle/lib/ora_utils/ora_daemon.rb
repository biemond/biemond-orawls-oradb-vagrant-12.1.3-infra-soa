require 'easy_type'

class OraDaemon < EasyType::Daemon
  include EasyType::Template

  ORACLE_ERROR    = /ORA-.*|SP-.*|SP2-.*/
  DEFAULT_TIMEOUT = 120 # 2 minutes


  def self.run(user, sid, oraUser='sysdba', oraPassword=nil, timeout = DEFAULT_TIMEOUT)
    daemon = super(identity(sid, oraUser))
    if daemon
      return daemon
    else
      new(user, sid, oraUser, oraPassword, timeout)
    end
  end

  def initialize(user, sid, oraUser, oraPassword, timeout)
    @user = user
    @sid = sid
    @oraUser = oraUser
    @oraPassword = oraPassword
    Puppet.info "Starting the Oracle daemon for user #{@user} on sid #{sid}"
    command = "export ORACLE_SID=#{@sid};export ORAENV_ASK=NO;. oraenv;sqlplus -S /nolog"
    super(self.class.identity(sid,oraUser), command, user)
    initial_setup
  end

  def execute_sql_command(command, output_file, timeout = DEFAULT_TIMEOUT)
    Puppet.debug "Executing sql-command #{command}"
    connect_to_oracle
    execute_command template('puppet:///modules/oracle/execute.sql.erb', binding)
    execute_command "prompt ~~~~COMMAND SUCCESFULL~~~~"
    sync(timeout) {|line| fail "Error in execution of SQL command: #{command}.\nFound error #{line}" if line =~ ORACLE_ERROR}
  end

  private

    def self.identity(sid, oraUser)
      "ora-#{sid}-#{oraUser}"
    end


    def connect_to_oracle
      Puppet.debug "Connecting to Oracle sid #{@sid} with user #{@oraUser}"
      case @oraUser.downcase
      when 'sysdba', 'sysasm'
        execute_command "connect / as #{@oraUser}\;"
      else
        execute_command "connect #{@oraUser}/#{@oraPassword};"
      end
    end

    def initial_setup
      execute_command template('puppet:///modules/oracle/setup.sql.erb', binding)
    end

end

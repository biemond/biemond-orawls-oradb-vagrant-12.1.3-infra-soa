require 'tempfile'
require 'fileutils'
require 'ora_utils/ora_daemon'
require 'ora_utils/ora_tab'

module OraUtils
  module OracleAccess

    def self.included(parent)
      parent.extend(OracleAccess)
    end


    ##
    #
    # Use this function to execute Oracle statements on a set of specfied sids
    #
    # @param sids [Array] Array of SIDS
    # @param command [String] this is the commands to be given
    #
    #
    def sql_on( sids, command, parameters = {})
      results = []
      sids.each do |sid|
        results = results + sql(command, {:sid => sid}.merge(parameters))
      end
      results
    end

    ##
    #
    # Use this function to execute Oracle statements
    #
    # @param command [String] this is the commands to be given
    #
    #
    def sql_on_all_sids( command, parameters = {})
      results = []
      oratab = OraTab.new
      oratab.running_database_sids.each do |sid|
        results = results + sql(command, {:sid => sid}.merge(parameters))
      end
      results
    end


    ##
    #
    # Use this function to execute Oracle statements
    #
    # @param command [String] this is the commands to be given
    #
    #
    def sql( command, parameters = {})
      sid = parameters.fetch(:sid) { fail "SID must be present"}
      Puppet.info "Executing: #{command} on database #{sid}"
      csv_string = execute_sql(command, parameters)
      add_sid_to(convert_csv_data_to_hash(csv_string, [], :converters=> lambda {|f| f ? f.strip : nil}),sid)
    end

    def execute_on_sid(sid, command_builder)
      command_builder.options.merge!(:sid => sid)
      nil
    end

    def execute_sql(command, parameters)
      os_user = parameters.fetch(:os_user) { ENV['ORA_OS_USER'] || 'oracle'}
      db_sid = parameters.fetch(:sid) { raise ArgumentError, "No sid specified"}
      username = parameters.fetch(:username) { 'sysdba'}
      password = parameters[:password] # null allowd
      daemon = OraDaemon.run(os_user, db_sid, username, password)
      outFile = Tempfile.new([ 'output', '.csv' ])
      outFile.close
      FileUtils.chown(os_user, nil, outFile.path)
      FileUtils.chmod(0644, outFile.path)
      if timeout_specified
        daemon.execute_sql_command(command, outFile.path, timeout_specified)
      else
        daemon.execute_sql_command(command, outFile.path)
      end
      File.read(outFile.path)
    end


    def add_sid_to(elements, sid)
      elements.collect{|e| e['SID'] = sid; e}
    end

    # This is a little hack to get a specified timeout value
     def timeout_specified
      if respond_to?(:to_hash)
        to_hash.fetch(:timeout) { nil} #
      else
        nil
      end
    end

    def sid_from_resource
      oratab = OraUtils::OraTab.new
      resource.sid.empty? ? oratab.default_sid : resource.sid
    end


  end
end
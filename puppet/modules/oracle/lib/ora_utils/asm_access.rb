require 'tempfile'
require 'fileutils'

module OraUtils
  module AsmAccess

    def self.included(parent)
      parent.extend(AsmAccess)
    end

    ##
    #
    # Use this function to execute asmcmd statements
    #
    # @param command [String] this is the commands to be given
    #
    #
    def asmcmd( command, parameters = {})
      Puppet.debug "Executing asmcmd command: #{command}"
      os_user = parameters.fetch(:os_user) { ENV['GRID_OS_USER'] || 'grid'}
      full_command = "export ORACLE_SID='+ASM1';export ORAENV_ASK=NO;. oraenv; asmcmd #{command}"
      options = {:uid => os_user, :failonfail => true}
      Puppet::Util::Execution.execute(full_command, options)
    end


  end
end
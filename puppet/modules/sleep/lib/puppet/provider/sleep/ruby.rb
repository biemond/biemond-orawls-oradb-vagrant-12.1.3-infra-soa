require 'puppet/util'
Puppet::Type.type(:sleep).provide(:ruby) do

  confine :feature => :posix

  def bedtime=(snoretime = resource[:bedtime])
    if resource[:wakeupfor] == :false
      sleep(snoretime)
    else
      starttime = Time.now.to_i
      tested = false
      timedout = false
      until tested or timedout
        command = "/bin/sh -c '#{resource[:wakeupfor]}'"
        debug("Running test: #{command}")
        output = Puppet::Util::Execution.execute(command, :failonfail => false, :combine => true)
        debug("The test returned: #{$CHILD_STATUS} #{output}")
        tested = true if $CHILD_STATUS == 0
        debug("Tested is: #{tested}")
        timedout = true if Time.now.to_i >= ( starttime + snoretime ) and snoretime > 0
        debug("Tested is: #{tested} calculated from #{starttime + snoretime} vs #{Time.now.to_i}")
        debug("Been running for #{Time.now.to_i - starttime} seconds")
        debug("Sleeping again")
        sleep(resource[:dozetime]) unless tested
      end
      @resource.fail if timedout and resource[:failontimeout] == true
    end
    
  end

end

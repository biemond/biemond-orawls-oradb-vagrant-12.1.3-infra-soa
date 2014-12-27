Puppet::Type.newtype(:sleep) do

  @doc = <<-EOS
    This type provides the capability to manage sleep
  EOS

  newparam(:name) do
    isnamevar
    desc "how long to sleep for"
  end

  newproperty(:bedtime) do
    desc "how long to sleep for"
    munge do |snore|
      Integer(snore)
    end
    validate do |zzzz|
      fail("sleepy time isn't an integer") unless zzzz =~ /^\d+$/
    end
    defaultto { @resource[:name] }

    def retrieve
      # We need to return :notrun to trigger evaluation; when that isn't
      # true, we *LIE* about what happened and return a "success" for the
      # value, which causes us to be treated as in_sync?, which means we
      # don't actually execute anything.  I think. --daniel 2011-03-10
      if @resource.check_all_attributes
        return :notrun
      else
        return self.should
      end
    end
    def sync
      provider.bedtime=self.should
    end
  end

  newparam(:wakeupfor) do
    desc "what to wake up for - a shell test for example"
    defaultto { :false }
  end

  newparam(:failontimeout) do
    desc "what to wake up for - a shell test for example"
    defaultto { :true }
  end

  newparam(:dozetime) do
    desc "where wakeupfor set, optional parameter to determine how often to run the test"
    defaultto { 60 }
    munge do |zzzz|
      Integer(zzzz)
    end
  end

  def self.newcheck(name, options = {}, &block)
    @checks ||= {}
    check = newparam(name, options, &block)
    @checks[name] = check
  end

  def self.checks
    @checks.keys
  end

  newcheck(:refreshonly) do
    newvalues(:true, :false)
    defaultto :true
    def check(value)
      # We have to invert the values.
      if value == :true
        false
      else
        true
      end
    end
  end
  def check_all_attributes(refreshing = false)
    self.class.checks.each { |check|
      next if refreshing and check == :refreshonly
      if @parameters.include?(check)
        val = @parameters[check].value
        val = [val] unless val.is_a? Array
        val.each do |value|
          return false unless @parameters[check].check(value)
        end
      end
    }

    true
  end

  def refresh
    self.property(:bedtime).sync
  end

end

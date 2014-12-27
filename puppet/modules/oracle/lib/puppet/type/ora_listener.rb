module Puppet
  newtype(:ora_
    listener) do
    desc "This is the oracle listener process"

    newproperty(:ensure) do
      desc "Whether a listener should be running."

      newvalue(:stopped, :event => :service_stopped) do
        provider.stop
      end

      newvalue(:running, :event => :service_started, :invalidate_refreshes => true) do
        provider.start
      end

      aliasvalue(:false, :stopped)
      aliasvalue(:true, :running)

      def retrieve
        provider.status
      end

      def sync
        event = super()

        if property = @resource.property(:enable)
          val = property.retrieve
          property.sync unless property.safe_insync?(val)
        end

        event
      end
    end

    newparam(:name) do
      desc <<-EOT
        The sid of the listner to run.
      EOT
      isnamevar
    end

  end
end

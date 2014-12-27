require 'easy_type/helpers'

module OraUtils
  #
  # Scan the outpout of AsmCmd volinfo -a into an Array of hashes used by
  # the `to_get_raw_resources` of easy_type
  # This is an example of some output:
  #
  #
  #Diskgroup Name: BACKUPDG
  #
  # Volume Name: ORABACKUP
  # Volume Device: /dev/asm/orabackup-51
  # State: ENABLED
  # Size (MB): 6144
  # Resize Unit (MB): 32
  # Redundancy: MIRROR
  # Stripe Columns: 4
  # Stripe Width (K): 128
  # Usage:
  # Mountpath:
  #
  #
  class AsmIndexParser

    def initialize(content)
      @parsed_content = []
      @content = content
    end

    def parse
      @content.lines do |line|
        @line = line.to_s
        Puppet.debug "asmcmd output : #{@line}"
        next if empty_line
        next if parse_diskgroup
        next if parse_volume_name
        next if parse_volume_device
        next if parse_size
        parse_mount_path
      end
      @parsed_content
    end

    private

    def empty_line
      @line.strip == "" ? true : false
    end

    def parse_diskgroup
      diskgroup = @line.scan(/Diskgroup Name: (.*)/).flatten.first
      diskgroup ? (@diskgroup = diskgroup; true) : false
    end

    def parse_volume_name
      volume_name = @line.scan(/Volume Name: (.*)/).flatten.first
      volume_name ? (@volume_name = volume_name; true) : false
    end

    def parse_volume_device
      volume_device = @line.scan(/Volume Device: (.*)/).flatten.first
      volume_device ? (@volume_device = volume_device; true) : false
    end

    def parse_size
      units, size = @line.scan(/Size \((.)B\): (.*)/).flatten
      if size
        @size  = size
        @units = units
        true
      else
        false
      end
    end

    #
    # Mount path is the last entry in a list of volumes.
    # Create a  new record in the return array when a mont path
    # is found
    #
    # TODO: Now SID is fixed to +ASM1. works in most situations, but we should
    # make it configurable to be consistent
    #
    def parse_mount_path
      mount_path = @line.scan(/Mountpath:(.*)?/).flatten.first
      if mount_path 
        row = EasyType::Helpers::InstancesResults[
            'name',           "#{@diskgroup}:#{@volume_name}@+ASM1",
            'SID',            '+ASM1',
            'volume_name',    @volume_name,
            'volume_device',  @volume_device, 
            'diskgroup',      @diskgroup, 
            'size',           "#{@size}#{@units}"
          ]
        @parsed_content << row
      end
    end

  end
end

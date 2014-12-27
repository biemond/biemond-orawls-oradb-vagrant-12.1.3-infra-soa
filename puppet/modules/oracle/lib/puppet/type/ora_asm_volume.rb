require 'pathname'
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent)
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent.parent.parent + 'easy_type' + 'lib')
require 'easy_type'
require 'ora_utils/asm_index_parser'
require 'ora_utils/asm_access'
require 'ora_utils/title_parser'


# @nodoc
module Puppet
  newtype(:ora_asm_volume) do
    include EasyType
    include ::OraUtils::AsmAccess
    extend ::OraUtils::TitleParser

    desc "The ASM volumes"

    ensurable
    
    set_command(:asmcmd)

    to_get_raw_resources do
      volume_info = asmcmd "volinfo -a"
      parser = OraUtils::AsmIndexParser.new(volume_info)
      parser.parse
    end

    on_create do | command_builder |
      "volcreate -G #{diskgroup} -s #{size} #{volume_name}"
    end

    on_modify do | command_builder|
      Puppet.info "Modification of asm volumes not supported yet"
    end

    on_destroy do |command_builder|
      "voldelete -G #{diskgroup} #{volume_name}"
    end

    map_title_to_sid([:diskgroup, :chop.to_proc], :volume_name) { /^((.*\:)?(@?.*?)?(\@.*?)?)$/}
    #
    # property  :new_property  # For every property and parameter create a parameter file
    #
    parameter :name
    parameter :sid
    parameter :volume_name
		parameter :diskgroup
    parameter :volume_device

		property  :size
    # -- end of attributes -- Leave this comment if you want to use the scaffolder

    #
  end
end

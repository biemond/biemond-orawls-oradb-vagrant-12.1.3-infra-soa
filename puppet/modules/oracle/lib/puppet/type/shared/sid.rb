require 'ora_utils/ora_tab'

newparam(:sid) do
  include EasyType

  desc "SID to connect to"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('SID')
  end

end

#
# This is to support installations where the oratab is not available during the parse,
# but is available when we apply the class
#

def sid
  oratab = OraUtils::OraTab.new
  self[:sid].empty? ? oratab.default_sid : self[:sid]
end

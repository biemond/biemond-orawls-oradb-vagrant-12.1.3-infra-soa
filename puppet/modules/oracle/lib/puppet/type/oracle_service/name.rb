require 'ora_utils/mungers'

newparam(:name) do
  include EasyType
  include OraUtils::Mungers::LeaveSidRestToUppercase

  isnamevar

  to_translate_to_resource do | raw_resource|
    sid = raw_resource.column_data('SID')
    service_name = raw_resource.column_data('NAME') 
    "#{sid}/#{service_name}"
	end

end

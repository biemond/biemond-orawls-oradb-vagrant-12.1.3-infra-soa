require 'ora_utils/mungers'

newparam(:name) do
  include EasyType
  include EasyType::Validators::Name
  include OraUtils::Mungers::LeaveSidRestToUppercase

  desc "The user name"

  isnamevar

  to_translate_to_resource do | raw_resource|
    sid = raw_resource.column_data('SID')
    username = raw_resource.column_data('USERNAME').upcase 
    "#{sid}/#{username}"
  end


end

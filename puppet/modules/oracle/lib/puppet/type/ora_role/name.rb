require 'ora_utils/mungers'

newparam(:name) do
  include EasyType
  include EasyType::Validators::Name
  include OraUtils::Mungers::LeaveSidRestToUppercase

  desc "The role name "

  isnamevar

  to_translate_to_resource do | raw_resource|
    sid = raw_resource.column_data('SID')
    role_name = raw_resource.column_data('ROLE').upcase 
    "#{role_name}@#{sid}"
	end

end

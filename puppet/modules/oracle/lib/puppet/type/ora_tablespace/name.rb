require 'ora_utils/mungers'

newparam(:name) do
  include EasyType
  include EasyType::Validators::Name
  include OraUtils::Mungers::LeaveSidRestToUppercase
  desc "The tablespace name"

  isnamevar

  to_translate_to_resource do | raw_resource|
    sid = raw_resource.column_data('SID')
    tablespace_name = raw_resource.column_data('TABLESPACE_NAME') 
    "#{tablespace_name}@#{sid}"
  end

end


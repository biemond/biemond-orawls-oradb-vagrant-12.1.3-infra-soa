require 'ora_utils/mungers'

newparam(:name) do
  include EasyType
  include EasyType::Validators::Name
  include OraUtils::Mungers::LeaveSidRestToUppercase

  desc "The full diskgroup name including SID"

  isnamevar

  to_translate_to_resource do | raw_resource|
    sid = raw_resource.column_data('SID')
    diskgroup_name = raw_resource.column_data('NAME').upcase
    "#{diskgroup_name}@#{sid}"
  end


end

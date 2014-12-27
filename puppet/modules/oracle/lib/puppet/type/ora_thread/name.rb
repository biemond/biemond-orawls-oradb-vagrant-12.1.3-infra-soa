require 'ora_utils/mungers'

newparam(:name) do
  include EasyType
  include EasyType::Validators::Name
  include OraUtils::Mungers::LeaveSidRestToUppercase

  desc "The full specfied thread name"

  isnamevar

  to_translate_to_resource do | raw_resource|
    sid = raw_resource.column_data('SID')
    thread_no = raw_resource.column_data('THREAD#')
    "#{thread_no}@#{sid}"
  end

end


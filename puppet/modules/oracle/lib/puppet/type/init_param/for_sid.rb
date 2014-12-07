newparam(:for_sid) do
  include EasyType
  include EasyType::Validators::Name
  desc "The SID you want to set the parameter for"

  isnamevar

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('FOR_SID')
  end

end
newparam(:service_name) do
  include EasyType

  desc "The service name"

  isnamevar

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('NAME')
  end

end

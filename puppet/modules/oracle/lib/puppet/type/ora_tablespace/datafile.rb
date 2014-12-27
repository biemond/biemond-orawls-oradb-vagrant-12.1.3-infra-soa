newparam(:datafile) do

  include EasyType
  desc "The name of the datafile"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('FILE_NAME')
  end

end

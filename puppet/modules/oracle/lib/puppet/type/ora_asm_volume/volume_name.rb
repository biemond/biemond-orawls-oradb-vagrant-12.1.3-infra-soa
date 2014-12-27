# encoding: UTF-8
newparam(:volume_name) do
  include EasyType
  

  desc 'The name of the volume to manage'
  
  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('volume_name')
  end

end
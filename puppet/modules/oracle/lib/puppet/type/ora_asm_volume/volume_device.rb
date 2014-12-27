# encoding: UTF-8

newparam(:volume_device) do
  include EasyType
  
  desc 'The device the volume is created on'

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('volume_device')
  end

end
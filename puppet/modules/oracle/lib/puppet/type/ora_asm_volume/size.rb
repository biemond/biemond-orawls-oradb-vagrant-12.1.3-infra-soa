# encoding: UTF-8


newproperty(:size) do
  include EasyType

  desc 'The size of the volume to ensure'
  
  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('size')
  end
  

end
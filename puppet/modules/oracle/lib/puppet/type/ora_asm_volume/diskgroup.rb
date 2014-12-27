# encoding: UTF-8


newparam(:diskgroup) do
  include EasyType

  desc 'The diskgroup into which we will create the volume'

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('diskgroup')
  end

end
newproperty(:value) do
  include EasyType

  desc "The value of the parameter"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('DISPLAY_VALUE')
  end


end

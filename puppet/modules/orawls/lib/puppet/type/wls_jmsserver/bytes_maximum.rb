newproperty(:bytes_maximum) do
  include EasyType

  desc 'Specifies whether message persistence is supported for this JMS server.'

  to_translate_to_resource do | raw_resource|
    raw_resource['bytes_maximum']
  end

end

newproperty(:password) do
  include EasyType
  desc "The password"

  to_translate_to_resource do | raw_resource|
    ''
  end

 on_apply do| command_builder|
    "identified by #{value}"
  end

end


newproperty(:extent_management) do
  include EasyType

  desc "TODO: Give description"
  newvalues(:local, :dictionary)

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('EXTENT_MAN').downcase.to_sym
  end

  on_apply do | command_builder|
    "extent management #{resource[:extent_management]}"
  end

end

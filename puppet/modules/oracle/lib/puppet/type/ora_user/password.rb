newparam(:password) do
  include EasyType

  desc "The user's password"
  defaultto 'password'

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('PASSWORD')
  end

end

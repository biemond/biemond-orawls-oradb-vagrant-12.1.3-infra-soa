newproperty(:logging) do
  include EasyType

  desc "TODO: Add description"
  newvalues(:yes, :no)


  to_translate_to_resource do | raw_resource|
    case raw_resource.column_data('LOGGING')
    when 'LOGGING' then :yes
    when 'NOLOGGING' then :no
    else
      fail('Invalid Logging found in tablespace resource.')
    end
  end

  on_apply do | command_builder|
    if resource[:logging] == :yes
      "logging"
    else
      "nologging"
    end
  end

end


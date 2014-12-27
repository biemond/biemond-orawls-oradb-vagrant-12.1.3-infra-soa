newproperty(:bigfile) do
  include EasyType

  desc "the type of datafile used for the tablespace"
  newvalues(:yes, :no)

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('BIG').downcase.to_sym
  end
end

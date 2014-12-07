newparam(:segment_space_management) do
  include EasyType

  desc "TODO: Give description"
  newvalues(:auto, :manual)

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('SEGMEN').downcase.to_sym
  end

end

newparam(:scope) do
  include EasyType
  include EasyType::Mungers::Upcase

  desc "The scope of the change."

  newvalues(:SPFILE, :MEMORY, :spfile, :memory)

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('SCOPE').upcase
  end


end

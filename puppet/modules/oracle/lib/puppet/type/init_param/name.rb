require 'ora_utils/mungers'

newparam(:name) do
  include EasyType
  include EasyType::Validators::Name

  desc "The parameter name"

  isnamevar

  to_translate_to_resource do | raw_resource|
    sid = raw_resource.column_data('SID')
    for_sid = raw_resource.column_data('FOR_SID')
    parameter_name = raw_resource.column_data('NAME').upcase
    scope = raw_resource.column_data('SCOPE').upcase
    if scope == 'MEMORY'
      "#{scope}/#{parameter_name}@#{sid}"
    else
      "#{scope}/#{parameter_name}:#{for_sid}@#{sid}"
    end
	end

end


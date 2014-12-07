newproperty(:diskgroup_state) do
  include EasyType
  include EasyType::Validators::Name
  include EasyType::Mungers::Upcase

  desc "The state of the diskgroup"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('STATE').upcase
  end

end

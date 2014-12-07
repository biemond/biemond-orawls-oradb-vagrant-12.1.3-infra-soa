newproperty(:redundancy_type) do
  include EasyType
  include EasyType::Validators::Name
  include EasyType::Mungers::Upcase

  desc "The redundancy type of the diskgroup"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('TYPE').upcase
  end

end

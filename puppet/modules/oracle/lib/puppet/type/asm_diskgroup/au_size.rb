newproperty(:au_size) do
  include EasyType
  include EasyType::Validators::Name
  include EasyType::Mungers::Upcase

  desc "The allocation unit size of the diskgroup"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('ALLOCATION_UNIT_SIZE').upcase
  end

end

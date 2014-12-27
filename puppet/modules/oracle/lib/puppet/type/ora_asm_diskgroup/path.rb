newproperty(:path) do
  include EasyType
  include EasyType::Validators::Name
  include EasyType::Mungers::Upcase

  desc "The path of the disks in the diskgroup"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('PATH').upcase
  end

end

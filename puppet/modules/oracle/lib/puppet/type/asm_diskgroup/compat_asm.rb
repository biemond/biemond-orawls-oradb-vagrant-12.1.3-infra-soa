newproperty(:compat_asm) do
  include EasyType
  include EasyType::Validators::Name
  include EasyType::Mungers::Upcase

  desc "The compatible asm attribute of the diskgroup"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('COMPATIBILITY').upcase
  end

  #
  # If the string length of the actual value is longer the the string length of the specified value,
  # only check if they are equal for the given string
  # example:
  #  12.1 == 12.1.0.0 
  #
  def insync?(is)
  	length = should.length
  	is.slice(0,length) == should
  end

end

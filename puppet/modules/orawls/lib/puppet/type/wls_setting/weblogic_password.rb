newproperty(:weblogic_password) do
  include EasyType

  desc 'weblogic password'
  defaultto 'weblogic1'

  to_translate_to_resource do |raw_resource|
    raw_resource[self.name]
  end
end

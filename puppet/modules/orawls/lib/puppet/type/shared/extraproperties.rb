newproperty(:extraproperties, :array_matching => :all) do
  include EasyType

  desc 'The extra properties'

  to_translate_to_resource do | raw_resource|
    unless raw_resource['extraproperties'].nil?
      raw_resource['extraproperties'].split(',')
    end
  end

  def insync?(is)
    if is.kind_of?(Array)
      is.sort == should.sort
    end
  end

end

def extraproperties
  self[:extraproperties] ? self[:extraproperties].join(',') : ''
end

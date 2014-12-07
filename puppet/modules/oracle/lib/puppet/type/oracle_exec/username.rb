newparam(:username) do
  include EasyType
  include EasyType::Validators::Name
  include EasyType::Mungers::Upcase

  defaultto 'sysdba'

  desc "The user name the command will run in. If none is specified, it will run as system"

end

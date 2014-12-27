require 'ora_utils/mungers'

newparam(:name) do
  desc "The sql command to execute"
  isnamevar

  include OraUtils::Mungers::LeaveSidRestToUppercase

end

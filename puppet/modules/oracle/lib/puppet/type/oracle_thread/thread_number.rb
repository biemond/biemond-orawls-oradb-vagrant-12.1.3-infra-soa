newparam(:thread_number) do
  include EasyType
  desc "The thread number"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('THREAD#')
  end

end


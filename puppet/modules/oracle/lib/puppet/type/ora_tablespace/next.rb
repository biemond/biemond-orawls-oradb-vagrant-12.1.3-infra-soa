newproperty(:next) do
  include EasyType
  include EasyType::Mungers::Size

	desc "Size of the next autoextent"

  to_translate_to_resource do | raw_resource|
  	block_size = raw_resource.column_data('BLOCK_SIZE').to_i
    increment = raw_resource.column_data('INCREMENT_BY').to_i
    increment * block_size
  end

  on_apply do | command_builder|
    "next #{resource[:next]}" if resource[:autoextend] == :on
  end

end

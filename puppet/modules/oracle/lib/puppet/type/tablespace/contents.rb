newproperty(:contents) do
  include EasyType

  desc "What does the tablespace contain? permanent, temporary of undo data"

  newvalues(:permanent, :temporary, :undo)

  to_translate_to_resource do | raw_resource|
    value = raw_resource.column_data('CONTENTS').downcase.to_sym
    if value == :permanent
    	nil
    else
    	value
    end
  end
end

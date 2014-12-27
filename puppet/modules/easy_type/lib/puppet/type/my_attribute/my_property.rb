# encoding: UTF-8


newproperty(:my_property) do

  include EasyType
  # Mungers
  # =======
  # If your property needs munging, you can include the necessary mungers. Check the documentation
  # of the Mungers to see which mungers are available
  #
  # Example:
  # --------
  #
  # include EasyType::Mungers::Upcase   # Check easy_type/validators for available mungers
  #
  # Explanation
  # -----------
  # This will include the Upcase munger. This will change any input in the Puppet Manifest
  # to an Uppercase value before comparing it with the actual value.
  #
  # Validators
  # ==========
  # If your property needs validation, you can include the necessary validator. Check the documentation
  # of the Validators to see which validators are available
  #
  # Example:
  # --------
  #
  # include EasyType::Validators::Name  # Check easy_type/validators for available validators
  #
  # Explanation
  # -----------
  # This will check if the content of the property is a valid name.

  desc 'Give your desciption of the property'

  #
  # to_translate_to_resource
  # ========================
  # Use this method to pick a part for the raw_resource hash. and translate it to the real resource hash
  # If you have used the `convert_csv_data_to_hash` method to create the Hash, you can use the
  # `column_data` method to pick the right element from the Hash. `column_data` will show an error
  # when the data is not available in the Hash.
  #
  # Example:
  # --------
  #
  # to_translate_to_resource do | raw_resource|
  #   raw_resource.column_data('USERNAME').upcase
  # end
  #
  # Explanation:
  # ------------
  #
  # This will extract the `USERNAME` from the `raw_resource` Hash and translate it to an uppercase
  # value. let's say, the Hash contains {'USERNAME` => 'micky_mouse`}. This would lead to the
  # following Puppet Resource
  #
  # example_type{micky_mouse: ensure => present,}
  #
  # Tricky stuff
  # ------------
  # Check what the keys of the Hash are. There **is** a difference between 'key', 'KEY', :KEY and :key
  #
  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('')
  end

  
  #
  # on_apply
  # ========
  # When Puppet signals it needs to create or modify the resource, it will call this method for every modified
  # property. It will then append the return value to the existing string from ether `on_create` or `on_modify`
  #
  # Example:
  # --------
  # in the type
  #
  #  on_command(:data_source)
  #
  #  on_modify do
  #    "alter #{name}"
  #  end
  #
  #  in the property
  #
  #  on_apply do | command_builder |
  #    "set destination #{destination} "
  #  end
  #
  # Explanation
  # ------------
  # When Puppet needs to modify the resource, the `data_source` method is called with parameter "alter my_name"
  # The `on_apply` method will append the text "set destination /dev/null" to the string.
  #
  # While the `on_create`, `on_destroy` and `on_modify` methods are called in the context of the
  # provider, the `on_apply` method is called in the context of the property.
  on_apply do
    'add_your_on_apply_information_for_this_property'
  end
  

end
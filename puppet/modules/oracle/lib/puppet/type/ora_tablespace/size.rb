newproperty(:size) do
  include EasyType
  include EasyType::Mungers::Size

  desc "The size of the tablespace"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('BYTES').to_i
  end


  def insync?(is)
    if smallfile? and smaller?
      Puppet.notice "Current size is #{current_size}, requested size: #{value}. Oracle doesn't support downsizing small file tablespaces"
      return true
    end
    if smallfile? and bigger?
      return false
    end
    if smallfile? and equal?
      return true
    end
    if bigfile?
      is == should
    end
  end



  on_modify do | command_builder|
    "resize #{resource[:size]}"
  end

  on_create do | command_builder|
    if resource[:datafile].nil?
      "datafile size #{resource[:size]}"
    else
      "datafile '#{resource[:datafile]}' size #{resource[:size]}"
    end
  end


  private

  def smaller?
    current_size > value
  end

  def bigger?
    current_size < value
  end

  def equal?
    current_size == value
  end

  def current_size
    provider.get(:size)
  end

  def bigfile?
    provider.get(:bigfile) == :yes
  end

  def smallfile?
    ! bigfile?
  end

end

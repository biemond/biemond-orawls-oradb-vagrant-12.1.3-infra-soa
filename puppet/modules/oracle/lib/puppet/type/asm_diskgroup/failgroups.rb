newproperty(:failgroups) do
  include EasyType
  include ::OraUtils::OracleAccess

  desc "The state of the diskgroup"

  to_translate_to_resource do | raw_resource|
    group_number = raw_resource.column_data('GROUP_NUMBER')
    sid = raw_resource.column_data('SID')
    oratab = OraUtils::OraTab.new
    sids = oratab.running_asm_sids
    @failgroups ||= sql_on( sids, 'select failgroup, group_number, path, name from v$asm_disk')
    failgroups_for(group_number, sid)
  end

  def self.failgroups_for(group_number, sid)
    translate(@failgroups.select{|q| q['GROUP_NUMBER'] == group_number && q['SID'] == sid})
  end

  def self.translate(raw)
    return_value = {}
    raw.each do |entry|
      return_value.merge!(failgroup(entry) => {'diskname' => entry['NAME'], 'path' => entry['PATH']})
    end
    return_value
  end

  def self.failgroup(raw)
    raw['FAILGROUP']
  end

end

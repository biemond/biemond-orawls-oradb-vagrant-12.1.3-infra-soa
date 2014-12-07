newproperty(:grants, :array_matching => :all) do
  include EasyType
  include ::OraUtils::OracleAccess
  include EasyType::Mungers::Upcase

  desc "grants for this user"

  to_translate_to_resource do | raw_resource|
    @all_rights ||= privileges + granted_roles
    user        = raw_resource.column_data('USERNAME').upcase
    sid         = raw_resource.column_data('SID')
    rights_for_user(user, sid)
  end

  #
  # because the order may differ, but they are still the same,
  # to decide if they are equal, first do a sort on is and should
  #
  def insync?(is)
    is.sort == should.sort
  end

  def change_to_s(from, to)
    return_value = []
    return_value << "revoked the #{revoked_rights.join(',')} right(s)" unless revoked_rights.empty?
    return_value << "granted the #{granted_rights.join(',')} right(s)" unless granted_rights.empty?
    return_value.join(' and ')
  end

  on_apply do | command_builder |
    sid = sid_from_resource
    if command_builder.line == "alter user #{resource[:username]}"
      command_builder.line = ""
    end
    command_builder.after(revoke(revoked_rights), :sid => sid) unless revoked_rights.empty?
    command_builder.after(grants(granted_rights), :sid => sid) unless granted_rights.empty?
    nil
  end

  private

    def current_rights
    # TODO: Check why this needs to be so difficult
    resource.to_resource.to_hash.delete_if {|key, value| value == :absent}.fetch(:grants) { []}
    end

    def expected_rights
      resource.to_hash.fetch(:grants) {[]}
    end

    def revoked_rights
      current_rights - expected_rights
    end

    def granted_rights
      expected_rights - current_rights
    end

    def revoke(rights)
      rights.empty? ? nil : "revoke #{rights.join(',')} from #{resource.username}"
    end

    def grants(rights)
      rights.empty? ? nil : "grant #{rights.join(',')} to #{resource.username}"
    end

    def self.rights_for_user(user, sid)
      @all_rights.select {|r| r['GRANTEE'] == user && r['SID'] == sid}.collect{|u| u['PRIVILEGE']}
    end


    def self.privileges
      sql_on_all_sids "select distinct grantee, privilege from dba_sys_privs"
    end

    def self.granted_roles
      sql_on_all_sids "select distinct grantee, granted_role as privilege from dba_role_privs"
    end

end

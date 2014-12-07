module OraUtils
	class OraTab

		DEFAULT_FILE		= "/etc/oratab"
		ASM_REGXP 			= /^\+ASM\d*$/
		NON_ASM_REGXP		= /^(?:(?!\+ASM\d*).)*$/

		def initialize(file = DEFAULT_FILE)
		  fail "oratab #{file} not found. Probably Oracle not installed" unless File.exists?(file)
		  @oratab = file
		end

		def entries
		  values = []
		  File.open(@oratab) do | oratab|
		    oratab.each_line do | line|
		      content = [:sid, :home, :start].zip(line.split(':'))
		      values << Hash[content] unless comment?(line)
		    end
		  end
		  values
		end

	  def sids
	    entries.collect{|i| i[:sid]}
	  end

	  def asm_sids
	  	sids.select{|sid| sid =~ ASM_REGXP}
	  end

	  def database_sids
	  	sids.select{|sid| sid =~ NON_ASM_REGXP}
	  end

	  def running_database_sids
	  	database_sids.select do |sid|
	  		`pgrep -f ^ora_pmon_#{sid}$` != ''
	  	end
	  end

	  def running_asm_sids
	  	asm_sids.select do |sid|
	  		`pgrep -f ^asm_pmon_\\\\#{sid}$` != ''
	  	end
	  end

	  def default_sid
	    database_sids.first
	  end

	  private
	    def comment?(line)
	      line.start_with?('#') || line.start_with?("\n")
	    end

  end
end
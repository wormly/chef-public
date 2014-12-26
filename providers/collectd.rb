
action :install do
	supportedPlatforms = %w[debian rhel]

	platform = node[:platform_family]
	
	isSupported = supportedPlatforms.include?(platform)
	
	log "This recipe is not supported for #{platform} platform family. The supported families are: #{supportedPlatforms.join(', ')}" do
		level :error
		not_if {isSupported}
	end
		
	return unless isSupported

	include_recipe "wormly-public::add_#{platform}_repo"

	package "wormly-collectd"

	params = new_resource.to_hash
	
	# relies on wormly-collectd-install using env vars equal to uppercase resource params
	%w{key hostname hostid wormlyhost mysqlhost mysqluser mysqlpassword mysqlsocket mysqlport verifyssl}.each do |name|
		value = params[name.to_sym].to_s
		
		case name
			when "verifyssl"
				value = value ? "true" : "false"
			else
				next unless value
		end
		
		vars[name] = value
	end

	params = vars.map{|k, v| "--#{k} #{v}"}.join(' )

	bash "install wormly collectd" do
		"wormly-collectd-setup #{params}"
		creates "/usr/share/wormly"
	end
end

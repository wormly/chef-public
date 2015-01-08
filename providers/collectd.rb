
action :install do
	case node[:platform_family]
		when "rhel"
			add_rhel_repo()
		when "debian"
			add_debian_repo()
		else
			log "This recipe is not supported for #{node[:platform_family]} platform family. The supported families are: rhel, debian" do
				level :error
			end
		
			return
	end

	package "wormly-collectd"

	params = new_resource.to_hash

	vars = {}
	
	# relies on wormly-collectd-install using env vars equal to uppercase resource params
	%w{key hostname hostid wormlyhost mysqlhost mysqluser mysqlpassword mysqlsocket mysqlport verifyssl}.each do |name|
		value = params[name.to_sym]
		
		case name
			when "verifyssl"
				value = value ? "true" : "false"
			else
				next unless value
		end
		
		vars[name] = value
	end

	params = vars.map{|k, v| "--#{k} #{v}"}.join(' ')

	command = "wormly-collectd-setup #{params}"

	keyless = command.gsub(vars["key"], "[apikey_hidden]")

	log "wormly setup command is: #{keyless}" do
		level :debug
	end

	flag = "/var/lib/wormly-collectd-installed"

	bash "install wormly collectd" do
		code command + " && touch #{flag}"
		creates flag
	end
end

def add_debian_repo
	wormlyKeyId = "5CAB7232"
	
	package "apt-transport-https"
	
	bash "apt update" do
		action :nothing
		code <<EOF
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys #{wormlyKeyId}
apt-get -y update
EOF
	end
	
	file "/etc/apt/sources.list.d/wormly.list" do
		content "deb https://#{new_resource.debbucket}.s3.amazonaws.com all main"
		notifies :run, "bash[apt update]", :immediately
	end
	 
	file "/etc/apt/sources.list.d/wormly-collectd.list" do
		content "deb https://#{new_resource.debbucket}.s3.amazonaws.com #{node[:lsb][:codename]} main"
		notifies :run, "bash[apt update]", :immediately
	end
end

def add_rhel_repo
	remote_file "/etc/pki/rpm-gpg/RPM-GPG-KEY-wormly" do
		source "https://#{new_resource.rpmbucket}.s3.amazonaws.com/public.gpg"
	end
	
	type = nil
	types = %w[amzn el5 el6]
	
	types.each do |val|
		type = val if node[:kernel][:release].include?(val)
	end
	
	log "Could not determine linux type as one of: "+types.join(', ') do
		level :error
		not_if {type}
	end
	
	return unless type
	
	file "/etc/yum.repos.d/wormly.repo" do
		content <<EOF
[wormly]
name=wormly
baseurl=https://#{new_resource.rpmbucket}.s3.amazonaws.com/#{type}/
enabled=1
gpgcheck=1
priority=8
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-wormly
EOF
	end
end

action :install do
	if platform_family?("debian")
		apt_repository 'wormly' do
			uri          new_resource.aptrepo
			distribution 'production'
			components   ['main']
			keyserver	 'keyserver.ubuntu.com'
			key	         new_resource.keyid
		end
	else
		keyname = "RPM-GPG-KEY-wormly"

		yum_key keyname do
			url new_resource.keyurl
		end

		# todo: use $releasever? is it present in all yums?
		el = IO.read("/proc/version").include?("el6") ? "el6" : "el5"

		yumrepo = new_resource.yumrepo.sub("$el", el)

		yum_repository 'wormly' do
			url yumrepo
			repo_name 'wormly'
			description 'Home for wormly-collectd package'
			key keyname
			includepkgs "wormly-collectd collectd"
			priority 5
		end
	end

	package "wormly-collectd" do
		notifies :run, "bash[setup]"
	end

	command = "wormly-collectd-setup --key #{new_resource.apikey}"

	values = new_resource.to_hash

	%w{hostname wormlyhost hostid mysqluser mysqlpassword mysqlhost mysqlport mysqlsocket}.each do |name|
		value = values[name.to_sym]

		next if value == ""

		command += " --#{name} #{value}"
	end

	bash "setup" do
		code <<EOF
#{command}
service collectd restart
EOF
		action :nothing
	end
end


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

		yum_repository 'wormly' do
			url new_resource.yumrepo
			repo_name 'wormly'
			description 'Home for wormly-collectd package'
			key keyname
		end
	end

	package "wormly-collectd" do
		notifies :run, "bash[setup]"
	end

	bash "setup" do
		code <<EOF
echo #{new_resource.apikey} | wormly-collectd-setup
service collectd restart
EOF
		action :nothing
	end
end


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
		end
	end

	package "wormly-collectd" do
		notifies :run, "bash[setup]"
	end

	hostname = new_resource.hostname != "" ? "--hostname #{new_resource.hostname}" : ""
	wormlyhost = new_resource.wormlyhost != "" ? "--wormlyhost #{new_resource.wormlyhost}" : ""
	hostid = new_resource.hostid != "" ? "--hostid #{new_resource.hostid}" : ""

	bash "setup" do
		code <<EOF
wormly-collectd-setup --key #{new_resource.apikey} #{hostname} #{wormlyhost} #{hostid}
service collectd restart
EOF
		action :nothing
	end
end


def prepare_debian
	apt_repository 'wormly' do
      uri          'http://wormly-deb.s3.amazonaws.com'
      distribution 'production'
      components   ['main']
      keyserver    'keyserver.ubuntu.com'
      key          '5CAB7232'
    end
end

def prepare_rhel
	keyname = "RPM-GPG-KEY-wormly"

	yum_key keyname do
		url "http://wormly-rpm.s3.amazonaws.com/public.gpg"
	end

	yum_repository 'wormly' do
		url 'http://wormly-rpm.s3.amazonaws.com/'
		repo_name 'wormly'
		description 'Home for wormly-collectd package'
		key keyname
	end
end

action :install do
	if platform_family?("debian")
		prepare_debian
	else
		prepare_rhel
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

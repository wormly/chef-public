
# not using deb cookbook since it's not cool to add dependencies just for this

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
	content "deb https://wormly-deb.s3.amazonaws.com all main"
	notifies :run, "bash[apt update]"
end
 
file "/etc/apt/sources.list.d/wormly-collectd.list" do
	content "deb https://wormly-deb.s3.amazonaws.com #{node[:lsb][:codename]} main"
	notifies :run, "bash[apt update]"
end 
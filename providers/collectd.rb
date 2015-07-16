
require 'digest'
require 'uri'

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

	if new_resource.hostid
		# TODO: test that supplied hostid works as expected
		hostid = new_resource.send "hostid"
		Chef::Log.info("Using supplied Wormly HostID")
	else
		Chef::Log.info("Fetching Wormly HostID from API")
		escapedHostName = URI.escape(new_resource.hostname)
		hostIdLookupCache = "/var/lib/wormly-hostcache-" + escapedHostName

		remote_file hostIdLookupCache do
			source "#{new_resource.apiendpoint}?key=#{new_resource.key}&response=json&cmd=createHost&idempotent=1&name=#{escapedHostName}"
			action :create_if_missing
		end

		ruby_block "parse hostid from createHost JSON response" do
			block do
				hash = JSON.parse(IO.read(hostIdLookupCache))
				hostid = hash["hostid"]
				Chef::Log.info("Parsed hostid #{hostid} from JSON")
			end
		end
	end

	ruby_block "install collectd-wormly" do
		block do
			Chef::Log.info("Wormly Host ID is #{hostid}")

			vars = {}

			# relies on wormly-collectd-install using env vars equal to uppercase resource params
			%w{key wormlyhost mysqlhost mysqluser mysqlpassword mysqlsocket mysqlport verifyssl}.each do |name|
				# http://cookbooks.opscode.com/cookbooks/resource_masher/versions/0.10.0#limitations-of-chef-default-functionality
				value = new_resource.send name
				
				case name
					when "verifyssl"
						value = value ? "true" : "false"
					else
						next unless value
				end
				
				vars[name] = value
			end
			vars["hostid"] = hostid

			params = vars.map{|k, v| "--#{k} #{v}"}.join(' ')
			params += " --nodbi" if new_resource.nodbi

			command = "collectd-wormly-setup #{params}"

			keyless = command
			keyless = keyless.gsub(vars["key"], "[apikey_hidden]") if vars.has_key?("key")
			keyless = keyless.gsub(vars["mysqlpassword"], "[mysqlpassword_hidden]") if vars.has_key?("mysqlpassword")

			Chef::Log.debug("Wormly setup command is #{keyless}")

			run_wormly_installer(command);
		end
	end

end

def run_wormly_installer(command)
	# Determine if our configuration parameters have changed:
	hash = Digest::SHA256.hexdigest command
	flag = "/var/lib/wormly-collectd-installed"

	# And, if they have, upgrade & execute the installer:

	package "collectd-wormly-config" do
		action :upgrade
		not_if "grep -qs #{hash} #{flag}"
	end

	bash "install wormly collectd" do
		code command + " && echo #{hash} > #{flag}"
		not_if "grep -qs #{hash} #{flag}"
	end
end


def add_debian_repo
	package "apt-transport-https"
	
	bash "apt update" do
		action :nothing
		code <<EOF
fetch() {
 wget -q $1 -O- || curl -s $1
}

fetch https://#{new_resource.debbucket}.s3.amazonaws.com/pubkey.gpg | apt-key add - 
apt-get -y update
EOF
	end
	
	file "/etc/apt/sources.list.d/wormly.list" do
		content "deb https://#{new_resource.debbucket}.s3.amazonaws.com all main"
		notifies :run, "bash[apt update]", :immediately
	end
	 
	file "/etc/apt/sources.list.d/collectd-wormly.list" do
		content "deb https://#{new_resource.debbucket}.s3.amazonaws.com #{node[:lsb][:codename]} main"
		notifies :run, "bash[apt update]", :immediately
	end
end

def add_rhel_repo

	bash "add yum repo" do
		action :nothing
		code <<EOF
# Discover which RHEL release (or compatible distro) we're running on:
ID=
types="el5 el6 el7 amzn"

function findid() {
	for val in $types; do
	grep -q $val <<< "$1" && ID=$val && return 0;
done

return 1
}

function findrelease() {
	filename=$1

	[ ! -e $filename ] && return 1

	for val in $types; do
	[[ $val != "el"* ]] && continue;
	num=$( cut -c3- <<< $val )
	grep -q "release $num" $filename && ID=$val && return 0;
	done

	return 1
}

findid "$(</proc/version)" || \
findid "`rpm --showrc | grep "\bdist\b"`" || \
findrelease /etc/redhat-release || \
findrelease /etc/system-release

[ -z "$ID" ] && echo "Could not determine your GNU/Linux distribution.  We support these ones: $types" && exit 1;

cat >/etc/yum.repos.d/wormly.repo <<END
[wormly]
name=wormly
baseurl=https://#{new_resource.rpmbucket}.s3.amazonaws.com/$ID/
enabled=1
gpgcheck=1
priority=8
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-wormly
END

EOF
	end

	remote_file "/etc/pki/rpm-gpg/RPM-GPG-KEY-wormly" do
		source "https://#{new_resource.rpmbucket}.s3.amazonaws.com/public.gpg"
		notifies :run, "bash[add yum repo]", :immediately
	end
end


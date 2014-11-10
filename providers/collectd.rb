
action :install do
	vars = {}

	params = new_resource.to_hash
	
	# relies on perl script using env vars equal to uppercase resource params
	%w{hostname hostid endpoint mysqlhost mysqluser mysqlpassword mysqlsocket mysqlport verifyssl}.each do |name|
		value = value ? "true" : "false" if name == "verifyssl"
	
		value = params[name.to_sym].to_s
		
		vars[name.upcase] = value
	end

	filename = Chef::Config[:file_cache_path]+"/init-shm.pl"

	endpoint = new_resource.endpoint

    flags = endpoint.include?(".dev") ? "--no-check-certificate" : ""
    
    bash "download" do
        code "wget #{flags} #{endpoint}/go -O "+filename
        creates filename
    end

	bash "setup collectd" do
		code "echo #{new_resource.apikey} | perl "+filename
		environment vars
		not_if "which collectd && [ -e /etc/wormly/types.db ]"
	end
end

action :remove do
	filename = Chef::Config[:file_cache_path]+"/remove-shm.pl"

	endpoint = new_resource.endpoint
    
    flags = endpoint.include?(".dev") ? "--no-check-certificate" : ""
	
	bash "download" do
		code "wget #{flags} #{endpoint}/remove -O "+filename
		creates filename
	end
	
	bash "remove" do
		code "perl "+filename
		only_if "which collectd"
	end
end
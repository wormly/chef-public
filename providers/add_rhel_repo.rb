
remote_file "/etc/pki/rpm-gpg/RPM-GPG-KEY-wormly" do
	source "https://wormly-rpm.s3.amazonaws.com/public.gpg"
end

type = nil
types = %w[amzn el5 el6]

for val in types; do
	type = val if node[:kernel][:release].include?(val)
done

log "Could not determine instance type as one of: #{types.join(', ')}" do
	level :error
	not_if {type}
end

return unless type
 
file "/etc/yum.repos.d/wormly.repo" do
	content <<EOF
[wormly]
name=wormly
baseurl=https://wormly-rpm.s3.amazonaws.com/#{type}/
enabled=1
gpgcheck=1
priority=8
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-wormly
EOF
end

actions :install
default_action :install

attribute :key, :kind_of => String, :name_attribute => true

attribute :hostid, :kind_of => [String, Integer], :default => nil
attribute :hostname, :kind_of => [String], :default => nil

attribute :wormlyhost, :kind_of => String, :default => "https://metrics.wormly.com"
attribute :apiendpoint, :kind_of => String, :default => "https://api.wormly.com"
attribute :verifyssl, :kind_of => [TrueClass, FalseClass], :default => true

attribute :mysqlpassword, :kind_of => String, :default => nil
attribute :mysqluser, :kind_of => String, :default => nil
attribute :mysqlhost, :kind_of => String, :default => nil
attribute :mysqlsocket, :kind_of => String, :default => nil
attribute :mysqlport, :kind_of => String, :default => nil

# DBI disabled by default, because it appears to be causing collectd-wormly -T to have non-zero exit code
attribute :nodbi, :kind_of => [TrueClass, FalseClass], :default => true

attribute :debbucket, :kind_of => String, :default => "wormly-com-deb"
attribute :rpmbucket, :kind_of => String, :default => "wormly-com-rpm"
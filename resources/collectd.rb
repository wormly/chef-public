
actions :install
default_action :install

attribute :key, :kind_of => String, :name_attribute => true

attribute :hostid, :kind_of => [String, Integer], :default => nil
attribute :wormlyhost, :kind_of => String, :default => "https://shm.wormly.com"
attribute :verifyssl, :kind_of => [TrueClass, FalseClass], :default => true

attribute :mysqlpassword, :kind_of => String, :default => nil
attribute :mysqluser, :kind_of => String, :default => nil
attribute :mysqlhost, :kind_of => String, :default => nil
attribute :mysqlsocket, :kind_of => String, :default => nil
attribute :mysqlport, :kind_of => String, :default => nil

attribute :debbucket, :kind_of => String, :default => "wormly-deb"
attribute :rpmbucket, :kind_of => String, :default => "wormly-rpm"
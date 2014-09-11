
actions :install, :remove
default_action :install

attribute :apikey, :kind_of => String, :name_attribute => true

attribute :hostname, :kind_of => String, :default => nil
attribute :hostid, :kind_of => String, :default => nil
attribute :endpoint, :kind_of => String, :default => "https://shm.wormly.com"
attribute :verifyssl, :kind_of => [TrueClass, FalseClass], :default => true

attribute :mysqlpassword, :kind_of => String, :default => nil
attribute :mysqluser, :kind_of => String, :default => nil
attribute :mysqlhost, :kind_of => String, :default => nil
attribute :mysqlsocket, :kind_of => String, :default => nil
attribute :mysqlport, :kind_of => String, :default => nil

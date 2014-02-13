
actions :install
default_action :install

attribute :apikey, :kind_of => String, :name_attribute => true

attribute :hostname, :kind_of => String, :default => ""
attribute :hostid, :kind_of => String, :default => ""
attribute :wormlyhost, :kind_of => String, :default => ""

attribute :mysqlpassword, :kind_of => String, :default => ""
attribute :mysqluser, :kind_of => String, :default => ""
attribute :mysqlhost, :kind_of => String, :default => ""
attribute :mysqlsocket, :kind_of => String, :default => ""
attribute :mysqlport, :kind_of => String, :default => ""

attribute :yumrepo, :kind_of => String, :default => "https://wormly-rpm.s3.amazonaws.com/$el/"
attribute :keyurl, :kind_of => String, :default => "https://wormly-rpm.s3.amazonaws.com/public.gpg"

attribute :aptrepo, :kind_of => String, :default => "https://wormly-deb.s3.amazonaws.com/"
attribute :keyid, :kind_of => String, :default => "5CAB7232"

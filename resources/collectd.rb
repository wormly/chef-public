
actions :install

attribute :apikey, :kind_of => String, :required => true

attribute :yumrepo, :kind_of => String, :default => "https://wormly-rpm.s3.amazonaws.com/"
attribute :keyurl, :kind_of => String, :default => "https://wormly-rpm.s3.amazonaws.com/public.gpg"

attribute :aptrepo, :kind_of => String, :default => "https://wormly-deb.s3.amazonaws.com/"
attribute :keyid, :kind_of => String, :default => "5CAB7232"

def initialize(*args)
  super
  @action = :install
end
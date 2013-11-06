
actions :install

attribute :apikey, :kind_of => String, :required => true

def initialize(*args)
  super
  @action = :install
end
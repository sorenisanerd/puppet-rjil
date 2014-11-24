Puppet::Type.newtype(:consul_kv) do

  @doc = <<-'EOD'
  Consul Key/value pair operations (Create, change, delete).
  e.g
  Add a key/value pair or change value of a key

  consul_kv{'foo/bar': value => 'baz'}

  Above code will create a key in consul named 'foo/bar' with value 'baz' if it
doesn't exist. If the key exists with different value, it will be changed.
  EOD

  ensurable

  newparam(:name, :namevar => true) do
    desc  'consul kv path. This is a relative path after /v1/kv.
    e.g setting key foo/bar will create the key under /v1/kv/foo/bar.'
  end

  newparam(:url) do
    desc 'Consul url to use'
    defaultto 'http://localhost:8500/v1/kv'
  end

  newproperty(:value) do
    desc 'Value to set'
  end

  validate do
    raise(Puppet::Error, 'Value should be set') unless self[:value]
  end

end

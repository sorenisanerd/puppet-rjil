Puppet::Type.newtype(:consul_kv_blocker) do

  desc <<-'EOD'
  Blocks until find specific consul Key/value pair.
  EOD

  newparam(:name, :namevar => true) do
    desc 'Consul Key name'
  end

  newparam(:try_sleep) do
    desc 'The amount of time to sleep between retries'
    defaultto 1
    munge do |v|
      Integer(v)
    end
  end

  newparam(:url) do
    desc 'Consul url to use'
    defaultto 'http://localhost:8500/v1/kv'
  end

  newproperty(:ready) do
    defaultto true
  end

  newparam(:tries) do
    desc 'The amount of times to retry before failing'
    defaultto 1
    munge do |v|
      Integer(v)
    end
  end

  validate do
    raise(Puppet::Error, 'Ready should not be set') unless self[:ready] == true
  end

end

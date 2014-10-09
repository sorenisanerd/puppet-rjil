Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin/","/usr/local/sbin/" ] }

node /etcd/ {

  include rjil::base
  include rjil::jiocloud::consul::bootstrapserver
  include rjil::jiocloud::consul::cron

  if $::etcd_discovery_token {
    $discovery = true
  } else {
    $discovery = false
  }
  class { 'rjil::jiocloud::etcd':
    discovery       => $discovery,
    discovery_token => $::etcd_discovery_token
  }
}

## setup ceph configuration and osds on st nodes
node /^st\d+/ {
  include rjil::base
  include rjil::ceph
  include rjil::ceph::osd
}

# single leader that will be used to ensure that all
# mons form a single cluster
node /^stmonleader1/ {
  include rjil::base
  include rjil::ceph
  include rjil::ceph::mon
  include rjil::ceph::osd
  rjil::profile { 'stmonleader': }
}

## setup ceph osd and mon configuration on ceph
## Mon nodes.
## Note: This node list can be derived from hiera - rjil::ceph::mon_config

node /^stmon\d+/ {
  include rjil::base
  include rjil::ceph
  include rjil::ceph::mon
  include rjil::ceph::osd
  rjil::profile { 'stmon': }
}

##
## Setup contrail nodes
##
node /^ct\d+/ {
  include rjil::base
  include rjil::redis
  include rjil::cassandra
  include rjil::rabbitmq
  include rjil::zookeeper
  include rjil::haproxy
  include rjil::haproxy::contrail
  include rjil::jiocloud::consul::agent
}

##
## oc is openstack controller node which will have all
## openstack controller applications
##

node /^oc\d+/ {
  include rjil::base
  include rjil::memcached
  include rjil::keystone
  include rjil::glance
  include rjil::jiocloud::consul::agent
}

#
# this is a variation of the controller that has a database installed
#

node /^ocdb\d+/ {
  include rjil::base
  include rjil::memcached
  include rjil::db
  include rjil::keystone
  include rjil::glance
  include rjil::jiocloud::consul::agent
  include openstack_extras::keystone_endpoints
  include rjil::keystone::test_user
  # ensure that we don't create keystone objects until
  # the service is operational
  ensure_resource('rjil::service_blocker', 'keystone-admin', {})
  Rjil::Service_blocker['keystone-admin'] -> Class['openstack_extras::keystone_endpoints']
  Rjil::Service_blocker['keystone-admin'] -> Class['rjil::keystone::test_user']
}

#
# A variation of the controller that also runs a load balancer
#

node /^oclb\d+/ {
  include rjil::base
  include rjil::memcached
  include rjil::db
  include rjil::keystone
  include rjil::glance
  include openstack_extras::keystone_endpoints
  include rjil::keystone::test_user
  include rjil::haproxy
  include rjil::haproxy::openstack
  include rjil::jiocloud::consul::agent
}

node /^cp\d+/ {
  include rjil::base
  include rjil::ceph
}

node /^haproxy\d+/ {
  include rjil::base
  include rjil::haproxy
  include rjil::haproxy::openstack
  include rjil::jiocloud::consul::agent
}

node /jiojenkins/ {
  include rjil::system::accounts
  include rjil::jiocloud::jenkins_slave
}

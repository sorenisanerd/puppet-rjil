##
## Class rjil::system::ntp
##
class rjil::system::ntp(
  $server = false,
) {

  ## hiera_configs required
  ## There will be two internal ntp servers which would be used for timesync on other servers
  ## ntp servers will be sync the time from external time source (or ril time servers)
  ## ::ntp::servers - An array of ntp server IP addresses
  ##                  For ntp servers this will be external ntp server and
  ##                  For other servers these will be internal ntp servers
  ## ::ntp::udlc - to enable sync with local clock if external servers are not available.
  ##               This will be useful on internal ntp servers if in some case external servers are not
  ##               available for some time.

  include ::ntp

  exec { "ntpdate":
    command     => "/usr/sbin/ntpdate-debian",
    refreshonly => true,
    subscribe   => File[$::ntp::params::config],
    before      => Service[ntp]
  }

  if $server {
    rjil::jiocloud::consul::service { 'ntp':
      port          => 123,
      check_command => '/usr/lib/jiocloud/tests/ntp.sh',
    }
  }

  ##
  ## Add tests
  ## There should be better tests, for now just adding process monitor
  ##
  rjil::test {'ntp.sh':}

}

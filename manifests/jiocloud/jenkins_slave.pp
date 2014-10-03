class rjil::jiocloud::jenkins_slave {
  $packages = ['openjdk-7-jre-headless',
               'sbuild',
               'ubuntu-dev-tools',
               'python-pip',
               'npm',
               'git',
               'python-lxml',
               'python-dev',
               'autoconf',
               'libtool',
               'haveged',
               'apt-cacher-ng',
               'debhelper',
               'pkg-config',
               'libxml2-utils']

  package { $packages:
    ensure => 'installed'
  }

  group { 'jiojenkins':
    ensure => 'present',
  }
    
  user { 'jiojenkins':
    gid => 'jiojenkins',
    managehome => true,
    ensure => 'present',
    groups => ['sbuild'],
    require => Package['sbuild']
  }

  ssh_authorized_key { 'jiojenkins':
    user => 'jiojenkins',
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCvzdgrPlMiFFE4F+tK0INhGhZGqHQCHYMlMcXjUMSJCu7DMetDyIcoZZyMXWtvjszmbnM8hEtJPrMeBcCigTpw6yZmZT1grhyv6XoSX9ig+NM+vvipsUkGA2oKLEe0jQve0PiJWPj2DGn9xroZzxqAz7zVdLJcqU/sspLlFn4sVqqD32fIIltI4jnIfmRlj9LK+tUW3ifjeuG40rFVLhF81szGybPRLQ8ZLtiuti1/4DBtjkLDkS2qkdrTBJfCNY0bWkyvKVRqdEm3YEJ2+y1HXpKp4vmqkagFa1s45H1Pij/7hiupX62FZQPWB2YDpISLfWWgyzIHo5BTzJXs5Wfd'
  }

  exec { "fetch-repo":
    command => "wget -O /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo",
    creates => "/usr/local/bin/repo"
  } ->
  file { "/usr/local/bin/repo":
    mode => "0755"
  }

  exec { "sbuild-keygen":
    command => "sbuild-update --keygen",
    require => [Package['sbuild'], Package['haveged']],
   creates => '/var/lib/sbuild/apt-keys/sbuild-key.pub'
  }

  rjil::jiocloud::jenkins_slave::schroot { 'trusty': }
  rjil::jiocloud::jenkins_slave::schroot { 'precise': }
}

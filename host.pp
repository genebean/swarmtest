file_line { 'default gateway device':
  path   => '/etc/sysconfig/network',
  line   => 'GATEWAYDEV="eth0"',
  before => Class['docker'],
  notify => Service['network'],
}

service { 'network':
  ensure => 'running',
  enable => true,
}

class { 'docker':
  docker_users => [ 'vagrant', ],
  log_driver   => 'journald',
}

class {'docker::compose':
  ensure => present,
}

if $facts['hostname'] == 'docker1' {
  Docker::Swarm <| |> -> Docker::Stack <| |>

  docker::swarm {'cluster_manager':
    init           => true,
    advertise_addr => $facts['networking']['interfaces']['eth1']['ip'],
    listen_addr    => $facts['networking']['interfaces']['eth1']['ip'],
    before         => [
      Exec['get swarm manager token'],
      Exec['get swarm worker token'],
    ],
  }

  exec { 'get swarm manager token':
    command => '/bin/docker swarm join-token -q manager > /vagrant/manager-token',
  }

  exec { 'get swarm worker token':
    command => '/bin/docker swarm join-token -q worker > /vagrant/worker-token',
  }

  docker::stack { 'testapp':
    ensure       => present,
    stack_name   => 'testapp',
    compose_file => '/vagrant/sample-compose.yml',
    require      => [Class['docker'], ],
  }

} else {
  if $facts['swarm_manager_token'] {
    docker::swarm {'cluster_manager':
      join           => true,
      advertise_addr => $facts['networking']['interfaces']['eth1']['ip'],
      listen_addr    => $facts['networking']['interfaces']['eth1']['ip'],
      manager_ip     => '172.16.0.11',
      token          => $facts['swarm_manager_token'],
    }
  } else {
    fail('The swarm_manager_token is missing')
  }
}

# Handles Qpid service
#
# @api private
class qpid::service {
  if $qpid::ensure == 'absent' {
    $_service_ensure = false
    $_service_enable = false
  } else {
    $_service_ensure = $qpid::service_ensure
    $_service_enable = $qpid::service_enable
  }

  service { 'qpidd':
    ensure     => $_service_ensure,
    enable     => pick($_service_enable, $_service_ensure),
    hasstatus  => true,
    hasrestart => true,
  }

  if $facts['systemd'] {
    if $qpid::open_file_limit and $qpid::ensure == 'present' {
      $ensure_limit = 'present'
      $limits = { 'LimitNOFILE' => $qpid::open_file_limit }
    } else {
      $ensure_limit = 'absent'
      $limits = { 'LimitNOFILE' => 1 } # https://github.com/camptocamp/puppet-systemd/pull/80
    }

    systemd::service_limits { 'qpidd.service':
      ensure          => $ensure_limit,
      restart_service => false,
      limits          => $limits,
      notify          => Service['qpidd'],
    }

    if $qpid::ssl and $qpid::ensure == 'present' {
      $_ssl_ensure = 'present'
    } else {
      $_ssl_ensure = 'absent'
    }

    systemd::dropin_file { 'wait-for-port.conf':
      ensure  => $_ssl_ensure,
      unit    => 'qpidd.service',
      content => template('qpid/wait-for-port.conf.erb'),
      notify  => Service['qpidd'],
    }

    if $qpid::ssl and $qpid::ensure == 'present' {
      ensure_packages(['iproute'])
      Package['iproute'] -> Systemd::Dropin_file['wait-for-port.conf']
    }
  }
}

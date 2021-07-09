# Handles Qpid Dispatch Router service
#
# @api private
class qpid::router::service {
  if $qpid::router::ensure == 'absent' {
    $_service_ensure = false
    $_service_enable = false
  } else {
    $_service_ensure = $qpid::router::service_ensure
    $_service_enable = $qpid::router::service_enable
  }

  service { 'qdrouterd':
    ensure     => $_service_ensure,
    enable     => pick($_service_enable, $_service_ensure),
    hasstatus  => true,
    hasrestart => true,
  }

  if $facts['systemd'] {
    if $qpid::router::open_file_limit and $qpid::router::ensure == 'present' {
      $ensure_limit = 'present'
      $limits = { 'LimitNOFILE' => $qpid::router::open_file_limit }
    } else {
      $ensure_limit = 'absent'
      $limits = { 'LimitNOFILE' => 1 } # https://github.com/camptocamp/puppet-systemd/pull/80
    }

    systemd::service_limits { 'qdrouterd.service':
      ensure          => $ensure_limit,
      restart_service => false,
      limits          => $limits,
      notify          => Service['qdrouterd'],
    }
  }
}

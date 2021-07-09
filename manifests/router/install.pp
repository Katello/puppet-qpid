# Installs Qpid router packages
#
# @api private
class qpid::router::install {
  if $qpid::router::ensure == 'absent' {
    $_package_ensure = 'purged'
  } else {
    $_package_ensure = 'installed'
  }

  package { $qpid::router::router_packages:
    ensure => $_package_ensure,
  }
}

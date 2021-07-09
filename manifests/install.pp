# Handles Qpid install
#
# @api private
class qpid::install {
  if $qpid::ensure == 'absent' {
    $_package_ensure = 'purged'
  } else {
    $_package_ensure = $qpid::version
  }

  class { 'qpid::tools':
    ensure => $qpid::ensure,
  }

  package { $qpid::server_packages:
    ensure => $_package_ensure,
  }

  if $qpid::auth and $qpid::ensure == 'present' {
    ensure_packages(['cyrus-sasl-plain'])
  }

  if $qpid::server_store {
    package { $qpid::server_store_package:
      ensure => $_package_ensure,
    }
  }
}

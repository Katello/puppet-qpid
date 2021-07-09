# Class to manage qpid tools package
#
# @param ensure
#  Specify 'present' to install qpid-tools package or 'absent' to remove the package and any dependencies
#
class qpid::tools (
  Enum['present', 'absent'] $ensure = 'present',
) {
  if $ensure == 'absent' {
    $_package_ensure = 'purged'
  } else {
    $_package_ensure = $ensure
  }

  package { 'qpid-tools':
    ensure => $_package_ensure,
  }
}

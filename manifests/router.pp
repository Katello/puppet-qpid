# Handles Qpid dispatch router package installations and configuration
#
# @param router_id
#   Unique router ID
# @param mode
#   Router mode
# @param config_file
#   Dispatch router config file location
# @param router_packages
#   The package to be installed
# @param open_file_limit
#   Limit number of open files - systemd distros only
# @param worker_threads
#   Number of worker threads
# @param hello_interval
#   Frequency in seconds of sending heartbeats from this router
# @param hello_max_age
#   Timeout of heartbeat before connections are dropped
# @param service_enable
#   Enable/disable qdrouterd service at boot
# @param service_ensure
#   Specify if qdrouterd should be running or stopped.
# @param ensure
#   Specify to explicitly enable Qpid Dispatch installs or absent to remove all packages and configs
#
class qpid::router (
  String $router_id = $qpid::router::params::router_id,
  String $mode = 'interior',
  Stdlib::AbsolutePath $config_file = '/etc/qpid-dispatch/qdrouterd.conf',
  Array[String] $router_packages = ['qpid-dispatch-router'],
  Optional[Integer] $open_file_limit = undef,
  Integer $worker_threads = $qpid::router::params::worker_threads,
  Optional[Integer] $hello_interval = undef,
  Optional[Integer] $hello_max_age = undef,
  Boolean $service_ensure = true,
  Optional[Boolean] $service_enable = undef,
  Enum['present', 'absent'] $ensure = 'present',
) inherits qpid::router::params {
  contain qpid::router::install
  contain qpid::router::config
  contain qpid::router::service

  Class['qpid::router::install'] -> Class['qpid::router::config'] ~> Class['qpid::router::service']
}

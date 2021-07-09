# Configure a qpid router listener
#
# @param ssl_profile
#   SSL profile to use
# @param host
#   Host/address to listen on
# @param port
#   Port to listen on
# @param sasl_mech
#   SASL mechanism to use
# @param role
#   Listener role
# @param idle_timeout
# @param config_file
#   The target for the concat fragment. Inherited from the main config so
#   usually not to be touched.
#   Timeout in seconds
define qpid::router::listener (
  Optional[String] $ssl_profile = undef,
  Optional[String] $host = undef,
  Integer[0, 65535] $port = 5672,
  Optional[String] $sasl_mech = 'ANONYMOUS',
  Optional[Enum['normal', 'inter-router', 'route-container']] $role = undef,
  Optional[Integer[0]] $idle_timeout = undef,
  String $config_file = $qpid::router::config_file,
) {
  concat::fragment { "qdrouter+listener_${title}.conf":
    target  => $config_file,
    content => template('qpid/router/listener.conf.erb'),
    order   => '05',
  }
}

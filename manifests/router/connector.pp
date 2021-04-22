# Configure a qpid router connector
#
# @param host
#   Host/address to listen on
# @param port
#   Port to listen on
# @param sasl_mech
#   SASL mechanism to use
# @param sasl_username
#   SASL username
# @param sasl_password
#   SASL password
# @param sasl_password_file
#   SASL password file
# @param role
#   Listener role
# @param ssl_profile
#   SSL profile to use
# @param idle_timeout
#   Timeout in seconds
# @param config_file
#   The target for the concat fragment. Inherited from the main config so
#   usually not to be touched.
define qpid::router::connector(
  String $host = '127.0.0.1',
  Integer[0, 65535] $port = 5672,
  Optional[String] $sasl_mech = 'ANONYMOUS',
  Optional[String] $sasl_username = undef,
  Optional[String] $sasl_password = undef,
  Stdlib::Absolutepath $sasl_password_file = '/etc/qpid-dispatch/connector_pw.conf',
  Optional[Enum['normal', 'inter-router', 'route-container']] $role = undef,
  Optional[String] $ssl_profile = undef,
  Optional[Integer[0]] $idle_timeout = undef,
  String $config_file = $qpid::router::config_file,
){

  if $sasl_password {
    include qpid::params

    file { $sasl_password_file:
      ensure  => file,
      owner   => 'root',
      group   => $qpid::params::group,
      mode    => '0640',
      content => $sasl_password,
    }
  } else {
    file { $sasl_password_file:
      ensure => absent,
    }
  }

  concat::fragment {"qdrouter+connector_${name}.conf":
    target  => $config_file,
    content => template('qpid/router/connector.conf.erb'),
    order   => '03',
  }

}

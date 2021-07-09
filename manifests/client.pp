# Handles Qpid client package installations and configuration
#
# @param version
#   The version to ensure. Can also be installed, latest or absent.
# @param config_file
#   Path to the configuration file
# @param log_level
# @param ssl
#   Whether to enable SSL.
# @param ssl_port
#   SSL port to connect to
# @param ssl_cert_db
#   Path to the SSL certificate database
# @param ssl_cert_password_file
#   Optional password for the file with the certificate database password
# @param ssl_cert_name
#   The name to use inside the certificate database
# @param client_packages
#   Packages to install
class qpid::client (
  String $version = $qpid::client::params::version,
  Stdlib::Absolutepath $config_file = $qpid::client::params::config_file,
  String $log_level = $qpid::client::params::log_level,
  Boolean $ssl = $qpid::client::params::ssl,
  Integer[0, 65535] $ssl_port  = $qpid::client::params::ssl_port,
  Optional[Stdlib::Absolutepath] $ssl_cert_db = $qpid::client::params::ssl_cert_db,
  Optional[Stdlib::Absolutepath] $ssl_cert_password_file = $qpid::client::params::ssl_cert_password_file,
  Optional[String] $ssl_cert_name = $qpid::client::params::ssl_cert_name,
  Array[String] $client_packages = $qpid::client::params::client_packages,
) inherits qpid::client::params {
  package { $client_packages:
    ensure => $version,
  } ->
  file { $config_file:
    ensure  => file,
    content => template('qpid/qpidc.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}

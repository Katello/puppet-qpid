# == Class: qpid
#
# Install and configure Qpid
#
# === Parameters:
#
# $log_level::                Logging level
#
# $acl_file::                 File name for Qpid ACL
#
# $acl_content::              Content for Access Control List file
#
# === SSL parameters
#
# $auth::                     Use SASL authentication
#
# $ssl::                      Use SSL with Qpid
#
# $ssl_port::                 SSL port to use
#
# $ssl_cert_db::              The SSL cert database to use
#
# $ssl_cert_password_file::   The SSL cert password file
#
# $ssl_cert_name::            The SSL cert name
#
# $ssl_require_client_auth::  Require client SSL authentication
#
# $session_unacked::          buffer if the broker has a large number of sessions and the memory overhead is a problem
#
# === Advanced parameters
#
# $max_connections::          Maximum number of connections to allow
#
# $wcache_page_size::         The size (in KB) of the pages in the write page cache
#
# $open_file_limit::          Limit number of open files - systemd distros only
#
# $log_to_syslog::            Log to syslog or not
#
# $interface::                Interface to listen on
#
# $server_store::             Install a Qpid message store
#
# $version::                  Package version to be installed
#
# $config_file::              Location of qpid configuration file
#
# $server_store_package::     Package name for the Qpid message store
#
# $user_groups::              Additional user groups to add the qpidd user to
#
# $server_packages::          List of server packages to install
#
# $mgmt_pub_interval::        Controls the interval at which the broker sends
#                             updated information (stats, etc.) to the management console.
#
# $default_queue_limit::      Default maximum size for queues (in bytes)
#
# $custom_settings::          Custom settings. Each entry will end up in the config file.
#                             The settings with can't be set this way and will cause the
#                             server to refuse to start up.
#
# $service_ensure::           Specify if qpidd service should be running or stopped
#
# $service_enable::           Enable qpidd service at boot
#
# $ensure::                   Specify to explicitly enable Qpid installs or absent to remove all packages and configs
#
# $data_dir::     Location on disk that qpid broker data is stored
#
class qpid (
  String $version = $qpid::params::version,
  Boolean $auth = $qpid::params::auth,
  String $config_file = $qpid::params::config_file,
  Optional[String] $acl_content = $qpid::params::acl_content,
  String $acl_file = $qpid::params::acl_file,
  String $log_level = $qpid::params::log_level,
  Boolean $log_to_syslog = $qpid::params::log_to_syslog,
  Optional[String] $interface = $qpid::params::interface,
  Boolean $server_store = $qpid::params::server_store,
  String $server_store_package = $qpid::params::server_store_package,
  Boolean $ssl = $qpid::params::ssl,
  Integer[0, 65535] $ssl_port = $qpid::params::ssl_port,
  Optional[Integer[0]] $session_unacked = $qpid::params::session_unacked,
  Optional[Stdlib::Absolutepath] $ssl_cert_db = $qpid::params::ssl_cert_db,
  Optional[Stdlib::Absolutepath] $ssl_cert_password_file = $qpid::params::ssl_cert_password_file,
  Optional[String] $ssl_cert_name = $qpid::params::ssl_cert_name,
  Optional[Boolean] $ssl_require_client_auth = $qpid::params::ssl_require_client_auth,
  Array[String] $user_groups = $qpid::params::user_groups,
  Array[String] $server_packages = $qpid::params::server_packages,
  Optional[Integer[1]] $max_connections = $qpid::params::max_connections,
  Optional[Integer[1]] $wcache_page_size = $qpid::params::wcache_page_size,
  Optional[Integer[1]] $open_file_limit = $qpid::params::open_file_limit,
  Optional[Integer[1]] $mgmt_pub_interval = $qpid::params::mgmt_pub_interval,
  Optional[Integer[1]] $default_queue_limit = $qpid::params::default_queue_limit,
  Hash[String, Variant[String, Integer]] $custom_settings = $qpid::params::custom_settings,
  Boolean $service_ensure = true,
  Optional[Boolean] $service_enable = undef,
  Enum['present', 'absent'] $ensure = 'present',
  Stdlib::AbsolutePath $data_dir = '/var/lib/qpidd',
) inherits qpid::params {
  if $ssl {
    assert_type(Boolean, $ssl_require_client_auth)
    assert_type(String, $ssl_cert_name)
    assert_type(Stdlib::Absolutepath, $ssl_cert_db)
    assert_type(Stdlib::Absolutepath, $ssl_cert_password_file)
  }

  include qpid::install
  include qpid::config
  contain qpid::service

  Class['qpid::install'] ~> Class['qpid::config'] ~> Class['qpid::service']
}

# Configures an SSL profile for Qpid Dispatch Router
#
# @param ca
#   Location of CA pem file
# @param cert
#   Location of certificate pem file
# @param key
#   Location of private key pem file
# @param ciphers
#   Enabled ciphers, in OpenSSL format
# @param protocols
#   Enabled TLS protocols (e.g. TLSv1.1, TLSv1.2)
# @param password
#   Password, if required
# @param config_file
#   The config file to use. This is an advanced parameter and normally doesn't
#   need to be set.
define qpid::router::ssl_profile (
  Stdlib::Absolutepath $ca,
  Stdlib::Absolutepath $cert,
  Stdlib::Absolutepath $key,
  Optional[String] $ciphers = undef,
  Optional[Array[String]] $protocols = undef,
  Optional[String] $password = undef,
  String $config_file = $qpid::router::config_file,
) {
  concat::fragment { "qdrouter+ssl_${title}.conf":
    target  => $config_file,
    content => template('qpid/router/ssl_profile.conf.erb'),
    order   => '02',
  }
}

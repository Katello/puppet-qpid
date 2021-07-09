# Configure qpid router logging
#
# @param module
#   Logging module to use
# @param level
#   Logging level to use (e.g., debug+, info+)
# @param timestamp
#   Enable timestamps
# @param output
#   Log file location
# @param config_file
#   The config file to use
define qpid::router::log (
  String $module = 'DEFAULT',
  String $level = 'info+',
  Boolean $timestamp = true,
  Variant[Stdlib::Absolutepath, Enum['syslog']] $output = '/var/log/qdrouterd.log',
  String $config_file = $qpid::router::config_file,
) {
  concat::fragment { "qdrouter+log_${title}.conf":
    target  => $config_file,
    content => template('qpid/router/log.conf.erb'),
    order   => '06',
  }
}

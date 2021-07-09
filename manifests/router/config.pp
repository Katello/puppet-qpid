# Handles Qpid Dispatch Router configuration
#
# @api private
class qpid::router::config {
  concat::fragment { 'qdrouter+header.conf':
    target  => $qpid::router::config_file,
    content => template('qpid/router/header.conf.erb'),
    order   => '01',
  }

  concat::fragment { 'qdrouter+footer.conf':
    target  => $qpid::router::config_file,
    content => template('qpid/router/footer.conf.erb'),
    order   => '100',
  }

  concat { $qpid::router::config_file:
    ensure => $qpid::router::ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  Concat::Fragment<| target == $qpid::router::config_file |> ~> Concat[$qpid::router::config_file]
}

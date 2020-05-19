# Class to activate the Nessus application
#  Internet connection required
#
class nessus::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  if $::nessus::proxy_host {
    if $::nessus::proxy_port == undef {
      fail("When nessus::proxy_host is provided, a nessus::proxy_port is mandatory")
    }
    exec { 'set proxy':
      command => "nessuscli fix --secure --set proxy=${::nessus::proxy_host}",
      path    => [ '/opt/nessus/bin', '/opt/nessus/sbin', '/bin' ],
      unless  => "test $(nessuscli fix --secure --show proxy | grep 'Current value' | awk '{print \$4}') = ${::nessus::proxy_host}",
    }
    exec { 'set proxy_port':
      command => "nessuscli fix --secure --set proxy_port=${::nessus::proxy_port}",
      path    => [ '/opt/nessus/bin', '/opt/nessus/sbin', '/bin' ],
      unless  => "test $(nessuscli fix --secure --show proxy_port | grep 'Current value' | awk '{print \$4}') = ${::nessus::proxy_port}",
    }
  }

  if $nessus::activation_code {
    # Nessus activation code is present in configuration.
    if ($facts['nessus_activation_code'] == undef) {
      # Custom fact "nessus_activation_code" has not been
      # set, i.e. Nessus needs to be activated.
      $run_activate_nessus = true
    } else {
      # Custom fact "nessus_activation_code" exists.
      if ($::nessus_activation_code != $nessus::activation_code) {
        # New Nessus activation code presented. Activate
        # Nessus again.
        $run_activate_nessus = true
      } else {
        # Current activation code is still current.
        $run_activate_nessus = false
      }
    }
  } else {
    # Without Nessus activation code we cannot activate
    # Nessus.
    $run_activate_nessus = false
  }

  if $run_activate_nessus {
    $activate_command = "nessuscli fetch --register-only ${nessus::activation_code}"

    exec { 'Activate Nessus':
      path    => [ '/opt/nessus/bin', '/opt/nessus/sbin' ],
      command => $activate_command,
      notify  => Exec['Wait 60 seconds for Nessus activation'],
    }

    # Wait, then restart nessusd after activation
    exec { 'Wait 60 seconds for Nessus activation':
      path        => [ '/bin' ],
      command     => 'sleep 60',
      refreshonly => true,
      notify      => Service[$nessus::service_name],
    }
  }
}

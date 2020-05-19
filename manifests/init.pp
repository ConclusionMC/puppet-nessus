# == Class: nessus
#
# Install and manage the Nessus vulnerability scanner.
#
# === Parameters
#
# @param activation_code The nessus code used to activate home or professional feeds.
# @param package_ensure Ensure the package is installed, latest, or absent.
# @param package_name The name of the package to install
# @param proxy_host Is the nessus behind a http_proxy
# @param proxy_port On what port is the http_proxy reachable
# @param service_ensure State if the service should be running or stopped.
# @param service_name The name of the nessus service.
# @param service_enable Should the service be enabled upon boot
# @param service_manage State if the service should be managed or ignored.
#
# === Examples
# @example
#  class { nessus:
#   activation_code => '9999-XXXX-9999-XXXX'
#  }
#
#  # Create a user.
#  nessus::user { 'admin':
#   password => '1adam12_1adam12',
#   admin    => true,
#  }
#
# === Authors
#
# Adam Crews <adam.crews@gmail.com>
# Fabian van der Hoeven <fvanderhoeven@conclusion.nl>
#
# === Copyright
#
# Copyright 2014 Adam Crews, unless otherwise noted.
#
class nessus (
  Optional[String[1]]                  $activation_code = undef,
  String[1]                            $package_ensure  = $nessus::params::package_ensure,
  String[1]                            $package_name    = $nessus::params::package_name,
  Optional[Stdlib::Host]               $proxy_host      = undef,
  Optional[Stdlib::Port::Unprivileged] $proxy_port      = undef,
  Nessus::Service::Ensure              $service_ensure  = $nessus::params::service_ensure,
  String[1]                            $service_name    = $nessus::params::service_name,
  Boolean                              $service_enable  = $nessus::params::service_enable,
  Boolean                              $service_manage  = $nessus::params::service_manage,
) inherits nessus::params {

  anchor { 'nessus::begin': }
  -> class { 'nessus::install': }
  -> class { 'nessus::config': }
  -> class { 'nessus::service': }
  -> anchor { 'nessus::end': }
}

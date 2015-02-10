# Class: dhcp
#
# This class provides a simple way to install a DHCP server
# It will install and configure the necessary packages.
#
# Parameters:
#   ['server']               - Whether to install the DHCP server
#                              (default: true)
#   ['server_ddns_update']   - Set ddns_update on dhcp::server
#   ['server_authoritative'] - Set authoritative on dhcp::server
#   ['server_log_facility']  - Set log level on dhcp::server
#   ['server_opts']          - Set opts for dhcp::server
#
# Actions:
#   - Deploys a DHCP server
#
# Sample usage:
#   include ::dhcp
#
# Requires:
#   - puppetlabs/stdlib
#   - ripienaar/concat
#
class dhcp (
  $server = true,
  $server_ddns_update = undef,
  $server_authoritative = undef,
  $server_log_facility = undef,
  $server_opts = undef,
) {
  if $server {
    class { '::dhcp::server':
      ddns_update   => $server_ddns_update,
      authoritative => $server_authoritative,
      log_facility  => $server_log_facility,
      opts          => $server_opts,
    }
  }
}

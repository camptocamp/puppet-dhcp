class dhcp (
  $server = true,
) {
  if $server {
    class { '::dhcp::server': }
  }
}

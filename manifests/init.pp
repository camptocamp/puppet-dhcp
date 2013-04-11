class dhcp (
  $server = true,
  $server_ddns_update = undef,
  $server_authoritative = undef,
  $server_opts = undef,
) {
  if $server {
    class { '::dhcp::server':
      ddns_update   => $server_ddns_update,
      authoritative => $server_authoritative,
      opts          => $server_opts,
    }
  }
}

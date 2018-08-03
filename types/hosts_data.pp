type Dhcp::Hosts_data = Hash[
  String,
  Struct[{
    'interfaces'              => Hash[Pattern[/^\S+$/], Pattern['^[A-Fa-f0-9:.]+$']],
    Optional['fixed_address'] => Pattern['^\S+$'],
    Optional['options']       => Array[String],
  }]
]

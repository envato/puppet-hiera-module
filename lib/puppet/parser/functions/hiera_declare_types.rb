module Puppet::Parser::Functions
  newfunction(:hiera_declare_types, :doc => "
Assigns built-in and user-defined resource types to a node. Built-in types require particluar
keys in hiera, whereas users may specify the key to be used to look for user-defined
resource types to declare.

To use `hiera_declare_types`, the following configuration is required:

- A key name to use for types e.g. `types` (The default is `types`, so you only need to
  pass a value if you want it to be different)
- 2 lines in the puppet `sites.pp` file (e.g. `/etc/puppet/manifests/sites.pp`).
  Since this is currently packaged as a module, include the module `include hiera`, then
  call `hiera_declare_types([])`. Note that this line must be outside any node
  definition and below any top-scope variables in use for Hiera lookups. You can call
  `hiera_declare_types` before or after `hiera_include`. Also note that an anonymous array
  has been passed as `hiera_declare_types` is currently implemented in a module rather than
  the puppet core.
- Node keys in the appropriate data sources. For built in types, the convention is
  `hiera_<type>`, so for the `file` type, it would be `hiera_file`, for `exec`, `hiera_exec`
  and so on. In a data source keyed to a node's role, one might have:
      ---
      hiera_file:
        hiera-node-type-demo:
         path: /var/lib/hiera-node-type-demo.txt
         ensure: file
         content: 'Hiera node/type mappings rule!'

  You can declare as many types as you want in this way. Note that you can use the hierachy
  and have similar definitions in other data source. If for example you have a default data
  source that defines another file type

      ---
      hiera_file:
        custom-software:
         path: /opt/custom-software
         ensure: directory
         mode: '0755'

  all of these file declarations will be made by hiera_declare_types! Lastly, you can declare
  user-defined resource types. For example, a mysql module may define a `mysql::db` type. To
  declare these with `hiera_declare_types([])` you might have

      ---
      types:
        - mysql::db
      # Use the same underscore convention and prefix with `hiera_` as with built-in types
      hiera_mysql_db:
        application_db:
         user: app_admin
         password: ^s0s3cur3$
         host: localhost
         grant:
           - all
") do |*args|

    # Support arbitrary field for third_party_key, default is 'types'
    third_party_key = 'types'
    custom_key      = args[0][0]
    if !custom_key.empty?
      third_party_key = custom_key
    end

    # We can search for the declaration of known types without the user having to tell us
    # which ones to look for. There will need to be a default value for each of these so the
    # lookups don't bomb out
    known_types =
      [
       'augeas', 'computer', 'cron', 'exec', 'file', 'filebucket', 'group', 'host',
       'interface', 'k5login', 'macauthorization', 'mailalias', 'maillist',
       'mcx', 'mount', 'nagios_command', 'nagios_contact', 'nagios_contactgroup',
       'nagios_host', 'nagios_hostdependency', 'nagios_hostescalation',
       'nagios_hostextinfo', 'nagios_hostgroup', 'nagios_service',
       'nagios_servicedependency', 'nagios_serviceescalation', 'nagios_serviceextinfo',
       'nagios_servicegroup', 'nagios_timeperiod', 'notify', 'package', 'resources',
       'router', 'schedule', 'scheduled_task', 'selboolean', 'selmodule',
       'service', 'ssh_authorized_key', 'sshkey', 'stage', 'tidy', 'user', 'vlan',
       'yumrepo', 'zfs', 'zone', 'zpool',
      ]

    # Load various functions
    Puppet::Parser::Functions.function('create_resources')
    Puppet::Parser::Functions.function('hiera_hash')

    # Load all the declarations for known types we can find
    known_types.each do |known_type|
      hiera_key = 'hiera_' + known_type
      hash      = function_hiera_hash([hiera_key, {}])
      if hash.length > 0
        function_create_resources([known_type, hash])
      end
    end

    # Users must enumerate the third-party resource types they're using, much like
    # enumerating classes for hiera_include('classes')
    raw_third_party_types = function_hiera_array([third_party_key, []])
    raw_third_party_types.each do |third_party_type|
      # Allow the double-colon notation for type enumeration, but use our 'hiera_' convention
      # for the actual type configuration
      hiera_key = 'hiera_' + third_party_type.sub('::', '_')
      hash      = function_hiera_hash([hiera_key, {}])

      if hash.length > 0
        function_create_resources([third_party_type, hash])
      end
    end

  end
end


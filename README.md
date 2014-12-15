# Hiera Puppet

## Description
This module configures [Hiera](https://github.com/puppetlabs/hiera) for Puppet.
The modules also provides `hiera_declare_types` which allows you to map type
definitions to nodes much like `hiera_include` for classes.

## Usage
This class will write out a hiera.yaml file in either /etc/puppetlabs/puppet/hiera.yaml or /etc/puppet/hiera.yaml (depending on if the node is running Puppet Enterprise or not).

```puppet
class { 'hiera':
  hierarchy => [
    '%{environment}/%{calling_class}',
    '%{environment}',
    'common',
  ],
}
```

The resulting output in /etc/puppet/hiera.yaml:
```yaml
---
:backends: - yaml
:logger: console
:hierarchy:
  - "%{environment}/%{calling_class}"
  - "%{environment}"
  - common

:yaml:
   :datadir: /etc/puppet/hieradata
```

### hiera_declare_types

Assigns built-in and user-defined resource types to a node. Built-in types require conventional 
keys in hiera, whereas users may specify the key to be used to look for user-defined
resource types to declare. Individual type declarations also have a conventional key notation.
**Note:** Currently no support for default 

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
```yaml
      ---
      hiera_file:
        hiera-node-type-demo:
         path: /var/lib/hiera-node-type-demo.txt
         ensure: file
         content: 'Hiera node/type mappings rule!'
```

  You can declare as many types as you want in this way. Note that you can use the hierachy
  and have similar definitions in other data sources. If for example you have a default data
  source that defines another file type

```yaml
      ---
      hiera_file:
        custom-software:
         path: /opt/custom-software
         ensure: directory
         mode: '0755'
```

  all of these file declarations will be made by `hiera_declare_types`! Lastly, you can declare
  user-defined resource types. For example, a mysql module may define a `mysql::db` type. To
  declare these with `hiera_declare_types([])` you might have

```yaml
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
```

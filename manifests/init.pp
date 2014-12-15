# == Class: hiera
#
# This class handles installing the hiera.yaml for Puppet's use.
#
# === Parameters:
#
# [*hierarchy*]
#   Hiera hierarchy.
#   Default: empty
#
# [*hiera_yaml*]
#   Heira config file.
#   Default: auto-set, platform specific
#
# [*datadir*]
#   Directory in which hiera will start looking for databases.
#   Default: auto-set, platform specific
#
# [*owner*]
#   Owner of the files.
#   Default: auto-set, platform specific
#
# [*group*]
#   Group owner of the files.
#   Default: auto-set, platform specific
#
# === Actions:
#
# Installs either /etc/puppet/hiera.yaml or /etc/puppetlabs/puppet/hiera.yaml.
# Links /etc/hiera.yaml to the above file.
# Creates $datadir.
#
# === Requires:
#
# Nothing
#
# === Sample Usage:
#
#   class { 'hiera':
#     hierarchy => [
#       '%{environment}',
#       'common',
#     ],
#   }
#
# === Authors:
#
# Hunter Haugen <h.haugen@gmail.com>
# Mike Arnold <mike@razorsedge.org>
# Nathan Nobbe <quickshiftin@gmail.com>
#
# === Copyright:
#
# Copyright (C) 2012 Hunter Haugen, unless otherwise noted.
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
# Copyright (C) 2013 Nathan Nobbe, unless otherwise noted.
#
class hiera (
  $hierarchy    = [],
  $backends     = $hiera::params::backends,
  $hiera_yaml   = $hiera::params::hiera_yaml,
  $datadir      = $hiera::params::datadir,
  $owner        = $hiera::params::owner,
  $group        = $hiera::params::group,
  $extra_config = '',
  ) inherits hiera::params {
  #------------------------------------------------------------
  # Default perms for all the declarations in this module
  #------------------------------------------------------------
  File {
    owner => $owner,
    group => $group,
    mode  => '0644',
  }
  
  #------------------------------------------------------------
  # Create the datadir
  # @note You probably don't want to distribute your data
  # source files with a module, so it's not supported here.
  #------------------------------------------------------------
  # This allows us to set datadir to values like
  # `/etc/puppet/environments/%{::environment}/hiera`.
  if $datadir !~ /%{.*}/ {
    file { $datadir:
      ensure => directory,
    }
  }

  #------------------------------------------------------------
  # Template uses $hierarchy, $datadir
  #------------------------------------------------------------
  file { $hiera_yaml:
    ensure  => present,
    content => template('hiera/hiera.yaml.erb'),
  }
  
  #------------------------------------------------------------
  # Symlink for hiera command line tool
  #------------------------------------------------------------
  file { '/etc/hiera.yaml':
    ensure => symlink,
    target => $hiera_yaml,
  }
}

class compute_train::install inherits compute_train::params {
#include compute_train::params

$cloud_role = $compute_train::cloud_role          

### Repository settings (remove old rpm and install new one)
  
  define removepackage {
    exec {
        "removepackage_$name":
            command => "/usr/bin/yum -y erase $name",
            onlyif => "/bin/rpm -ql $name",
    }
  }

  $oldrelease = [ 'centos-release-openstack-rocky',
                ]

  $oldpackage = [ 'centos-release-ceph-luminous',
                ]

  $newrelease =  'centos-release-openstack-train'

  $genericpackages = [   "openstack-utils",
                         "yum-plugin-priorities",
                         "ipset",
                         "sysfsutils", ]

  $neutronpackages = [   "openstack-neutron",
                         "openstack-neutron-openvswitch",
                         "openstack-neutron-common",
                         "openstack-neutron-ml2", ]

  $novapackages = [ "openstack-nova-compute",
                     "openstack-nova-common", ]

  file { "/etc/yum/vars/contentdir":
         path    => '/etc/yum/vars/contentdir',
         ensure  => 'present',
         content => 'centos',
  } ->

  compute_train::install::removepackage{
     $oldrelease :
  } ->

  compute_train::install::removepackage{
     $oldpackage :
  } ->

  exec { "clean repo cache":
         command => "/usr/bin/yum clean all",
         onlyif => "/bin/rpm -qi centos-release-ceph-nautilus.noarch | grep 'not installed'",
  } ->

  package { $newrelease :
    ensure => 'installed',
  } ->

  ### FF update a stein e train consiglia di disabilitare EPEL  
  exec { "yum disable EPEL repo":
         command => "/usr/bin/yum-config-manager --disable epel",
         onlyif => "/bin/rpm -qa | grep centos-release-openstack-train && /usr/bin/yum repolist enabled | grep epel/",
         timeout => 3600,
  } -> 

  exec { "yum update complete in DELL hosts":
         command => "/usr/bin/yum -y --disablerepo dell-system-update_independent --disablerepo dell-system-update_dependent -x facter update",
         onlyif => "/bin/rpm -qi dell-system-update | grep 'Architecture:' &&  /usr/bin/yum list installed | grep openstack-neutron.noarch | grep -i 'rocky'",
         timeout => 3600,
  } ->

  exec { "yum update complete":
         command => "/usr/bin/yum -y update",
         onlyif => "/bin/rpm -qi dell-system-update | grep 'not installed' &&  /usr/bin/yum list installed | grep openstack-neutron.noarch | grep -i 'rocky'",
         timeout => 3600,
  } ->

# Rename nova config file  
  exec { "mv_nova_conf_old":
         command => "/usr/bin/mv /etc/nova/nova.conf /etc/nova/nova.conf.rocky",
         onlyif  => "/usr/bin/test -e /etc/nova/nova.conf.rpmnew",
  } ->
 
  exec { "mv_nova_conf_new":
         command => "/usr/bin/mv /etc/nova/nova.conf.rpmnew /etc/nova/nova.conf",
         onlyif  => "/usr/bin/test -e /etc/nova/nova.conf.rpmnew",
  } ->

# Rename neutron config file  
  exec { "mv_neutron_conf_old":
         command => "/usr/bin/mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.rocky",
         onlyif  => "/usr/bin/test -e /etc/neutron/neutron.conf.rpmnew",
  } ->

  exec { "mv_neutron_conf_new":
         command => "/usr/bin/mv /etc/neutron/neutron.conf.rpmnew /etc/neutron/neutron.conf",
         onlyif  => "/usr/bin/test -e /etc/neutron/neutron.conf.rpmnew",
  } ->

  exec { "mv_neutron_openvswitch_old":
         command => "/usr/bin/mv /etc/neutron/plugins/ml2/openvswitch_agent.ini /etc/neutron/plugins/ml2/openvswitch_agent.ini.rocky",
         onlyif  => "/usr/bin/test -e /etc/neutron/plugins/ml2/openvswitch_agent.ini.rpmnew",
  } ->

  exec { "mv_neutron_openvswitch_new":
         command => "/usr/bin/mv /etc/neutron/plugins/ml2/openvswitch_agent.ini.rpmnew /etc/neutron/plugins/ml2/openvswitch_agent.ini",
         onlyif  => "/usr/bin/test -e /etc/neutron/plugins/ml2/openvswitch_agent.ini.rpmnew",
  } ->


  exec { "mv_neutron_ml2_old":
         command => "/usr/bin/mv /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.rocky",
         onlyif  => "/usr/bin/test -e /etc/neutron/plugins/ml2/ml2_conf.ini.rpmnew",
  } ->

  exec { "mv_neutron_ml2_new":
         command => "/usr/bin/mv /etc/neutron/plugins/ml2/ml2_conf.ini.rpmnew /etc/neutron/plugins/ml2/ml2_conf.ini",
         onlyif  => "/usr/bin/test -e /etc/neutron/plugins/ml2/ml2_conf.ini.rpmnew",
  } ->

# Rename puppet auth file  
  exec { "mv_puppet_auth_old":
         command => "/usr/bin/mv /etc/puppet/auth.conf /etc/puppet/auth.conf.rocky",
         onlyif  => "/usr/bin/test -e /etc/puppet/auth.conf.rpmnew",
  } ->

  exec { "mv_puppet_auth_new":
         command => "/usr/bin/mv /etc/puppet/auth.conf.rpmnew /etc/puppet/auth.conf",
         onlyif  => "/usr/bin/test -e /etc/puppet/auth.conf.rpmnew",
  } ->

## Install generic packages
  package { $genericpackages: 
    ensure => "installed",
    require => Package[$newrelease]
   } ->

  package { $neutronpackages: 
    ensure => "installed",
    require => Package[$newrelease]
  } ->

  package { $novapackages: 
    ensure => "installed",
    require => Package[$newrelease]
  } ->
  
  file_line { '/etc/sudoers.d/neutron  syslog':
               path   => '/etc/sudoers.d/neutron',
               line   => 'Defaults:neutron !requiretty, !syslog',
               match  => 'Defaults:neutron !requiretty',
            }
 
if $::compute_train::cloud_role == "is_prod_localstorage" or $::compute_train::cloud_role ==  "is_prod_sharedstorage" {                             
   package { 'glusterfs-fuse':
              ensure => 'installed',
           }
                                                                                     } 
}

class compute_ussuri::install inherits compute_ussuri::params {
#include compute_ussuri::params

$cloud_role = $compute_ussuri::cloud_role          

### Repository settings (remove old rpm and install new one)
  
  define removepackage {
    exec {
        "removepackage_$name":
            command => "/usr/bin/yum -y erase $name",
            onlyif => "/bin/rpm -ql $name",
    }
  }

  $oldrelease = [ 'centos-release-openstack-ocata',
                  'centos-release-ceph-jewel',
                ]

  $newrelease =  'centos-release-openstack-rocky'

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

  exec { "removepackage_zeromq":
         command => "/usr/bin/yum -y erase zeromq",
         onlyif => "/bin/rpm -qa | grep centos-release-openstack-ocata",
  } ->

  
  exec { "removepackage_ceilometer":
         command => "/usr/bin/yum -y erase *ceilometer*",
         onlyif => "/bin/rpm -qa | grep centos-release-openstack-ocata",
  } ->

  exec { "removepackage_ceph-release":
         command => "/usr/bin/yum -y erase ceph-release",
         onlyif => "/bin/rpm -qa | grep centos-release-openstack-ocata",
  } ->

  compute_ussuri::install::removepackage{
     $oldrelease :
  } ->

  exec { "install ceph-release nautilus":
         command => "/usr/bin/yum -y install https://download.ceph.com/rpm-nautilus/el7/noarch/ceph-release-1-1.el7.noarch.rpm",
         onlyif => "/bin/rpm -qi ceph-release | grep 'not installed'",
  } ->

  exec { "clean repo cache":
         command => "/usr/bin/yum clean all",
         onlyif => "/bin/rpm -qi zeromq | grep 'not installed'",
  } ->

  exec { "yum install ceph-common":
         command => "/usr/bin/yum -y install ceph-common",
         onlyif => "/bin/rpm -qi zeromq | grep 'not installed'",
         timeout => 1800,
  } ->

  exec { "yum update to force the installation of nautilus ceph-release in DELL hosts":
         command => "/usr/bin/yum -y --disablerepo dell-system-update_independent --disablerepo dell-system-update_dependent -x facter update",
         onlyif => "/bin/rpm -qi zeromq | grep 'not installed' &&  /bin/rpm -qi dell-system-update | grep 'Architecture:'",
         timeout => 3600,
  } ->

  exec { "yum update to force the installation of nautilus ceph-release":
         command => "/usr/bin/yum -y -x puppet -x facter update",
         onlyif => "/bin/rpm -qi zeromq | grep 'not installed' &&  /bin/rpm -qi dell-system-update | grep 'not installed'",
         timeout => 3600,
  } ->

  exec { "yum install libvirt before the openstack-nova-compute":
         command => "/usr/bin/yum -y install libvirt",
         onlyif => "/bin/rpm -qi zeromq | grep 'not installed'",
         timeout => 3600,
  } ->

  package { $newrelease :
    ensure => 'installed',
  } ->

  exec { "yum update complete in DELL hosts":
         command => "/usr/bin/yum -y --disablerepo dell-system-update_independent --disablerepo dell-system-update_dependent -x facter update",
         onlyif => "/bin/rpm -qi zeromq | grep 'not installed' && /bin/rpm -qi dell-system-update | grep 'Architecture:'",
         timeout => 3600,
  } ->

  exec { "yum update complete":
         command => "/usr/bin/yum -y -x puppet -x facter update",
         onlyif => "/bin/rpm -qi zeromq | grep 'not installed' &&  /bin/rpm -qi dell-system-update | grep 'not installed'",
         timeout => 3600,
  } ->


## Rename nova config file  
  exec { "mv_nova_conf_old":
         command => "/usr/bin/mv /etc/nova/nova.conf /etc/nova/nova.conf.ocata",
         onlyif  => "/usr/bin/test -e /etc/nova/nova.conf.rpmnew",
  } ->
 
  exec { "mv_nova_conf_new":
         command => "/usr/bin/mv /etc/nova/nova.conf.rpmnew /etc/nova/nova.conf",
         onlyif  => "/usr/bin/test -e /etc/nova/nova.conf.rpmnew",
  } ->

  exec { "yum install openstack-neutron":
         command => "/usr/bin/yum -y install openstack-neutron openstack-neutron-openvswitch openstack-neutron-common openstack-neutron-ml2",
         onlyif => "/bin/rpm -qi zeromq | grep 'not installed'",
         timeout => 1800,
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
 
if $::compute_ussuri::cloud_role == "is_prod_localstorage" or $::compute_ussuri::cloud_role ==  "is_prod_sharedstorage" {                             
   package { 'glusterfs-fuse':
              ensure => 'installed',
           }
                                                                                     } 
}

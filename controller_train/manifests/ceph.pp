class controller_train::ceph inherits controller_train::params {

    yumrepo { "ceph":
               baseurl             => "http://download.ceph.com/rpm-luminous/el7/$::architecture/",
               descr               => "Ceph packages for $::architecture",
               enabled             => 1,
               gpgcheck            => 1,
               gpgkey              => 'https://download.ceph.com/keys/release.asc',
            }
    yumrepo { "ceph-noarch":
               baseurl             => "http://download.ceph.com/rpm-luminous/el7/noarch",
               descr               => "Ceph packages for noarch",
               enabled             => 1,
               gpgcheck            => 1,
               gpgkey              => 'https://download.ceph.com/keys/release.asc',
            }

     package { 'ceph-common':
              ensure => 'installed',
              require => [ Yumrepo["ceph-noarch"], Yumrepo["ceph"] ]
             }
####ceph.conf, ceph.client.cinder ceph.client.glance keyring file are in /controller_train/files dir
                                                            
     file {'ceph.conf':
            source      => 'puppet:///modules/controller_train/ceph.conf',
            path        => '/etc/ceph/ceph.conf',
            backup      => true,
            require => Package["ceph-common"],
          }
     file {'ceph-ec.conf':
            source      => 'puppet:///modules/controller_train/ceph-ec.conf',
            path        => '/etc/ceph/ceph-ec.conf',
            backup      => true,
            require => Package["ceph-common"],
          }

  if $::controller_train::cloud_role == "is_production" {

      file {'cinder-prod.keyring':
              source      => 'puppet:///modules/controller_train/ceph.client.cinder-prod.keyring',
              path        => '/etc/ceph/ceph.client.cinder-prod.keyring',
              backup      => true,
              owner   => cinder,
              group   => cinder,
              mode    => "0640",
              require => Package["ceph-common"],
           }

      file {'glance-prod.keyring':
              source      => 'puppet:///modules/controller_train/ceph.client.glance-prod.keyring',
              path        => '/etc/ceph/ceph.client.glance-prod.keyring',
              backup      => true,
              owner   => glance,
              group   => glance,
              mode    => "0640",
              require => Package["ceph-common"],
         }

  }                          
      
  if $::controller_train::cloud_role == "is_test" {

      file {'cinder-cloudtest.keyring':
              source      => 'puppet:///modules/controller_train/ceph.client.cinder-cloudtest.keyring',
              path        => '/etc/ceph/ceph.client.cinder-cloudtest.keyring',
              backup      => true,
              owner   => cinder,
              group   => cinder,
              mode    => "0640",
              require => Package["ceph-common"],
           }

      file {'glance-test.keyring':
              source      => 'puppet:///modules/controller_train/ceph.client.glance-cloudtest.keyring',
              path        => '/etc/ceph/ceph.client.glance-cloudtest.keyring',
              backup      => true,
              owner   => glance,
              group   => glance,
              mode    => "0640",
              require => Package["ceph-common"],
         }

  }                 
} 

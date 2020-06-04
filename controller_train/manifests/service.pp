class controller_ussuri::service inherits controller_ussuri::params {
  
 ## Services

 service { "memcached":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_horizon'],
           }

 service { "fetch-crl-cron":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
           }

         
 # Services for keystone       
    service { "httpd":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => [ Class['controller_ussuri::configure_keystone'], Class['controller_ussuri::configure_horizon'], ],
           }

 # Services for Glance
    service { "openstack-glance-api":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_glance'],
           }
    service { "openstack-glance-registry":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_glance'],
            }

 # Services for nova       
    service { "openstack-nova-api":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_nova'],
           }
    service { "openstack-nova-consoleauth":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_nova'],
           }
    service { "openstack-nova-scheduler":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_nova'],
           }
    service { "openstack-nova-novncproxy":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_nova'],
           }
    service { "openstack-nova-conductor":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_nova'],
           }
    ## FF Da pike openstack-nova-cert non c'e' piu'
    #service { "openstack-nova-cert":
    #               ensure      => running,
    #               enable      => true,
    #               hasstatus   => true,
    #               hasrestart  => true,
    #               subscribe   => Class['controller_ussuri::configure_nova'],
    #       }
    ###
            
 # Services for ec2       
    service { "openstack-ec2-api":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_ec2'],
           }
    service { "openstack-ec2-api-metadata":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_ec2'],
           }

 # Services for neutron       
    service { "openvswitch":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_neutron'],
           }
    service { "neutron-server":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_neutron'],
           }
    service { "neutron-openvswitch-agent":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_neutron'],
           }
    service { "neutron-dhcp-agent":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_neutron'],
           }
    service { "neutron-metadata-agent":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_neutron'],
           }
    service { "neutron-l3-agent":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_neutron'],
           }

 # Services for cinder
    service { "openstack-cinder-api":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_cinder'],
           }
    service { "openstack-cinder-scheduler":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_cinder'],
           }
    service { "openstack-cinder-volume":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_cinder'],
           }
    service { "target":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_cinder'],
           }
           
 # Services for heat
    service { "openstack-heat-api":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_heat'],
           }
    service { "openstack-heat-api-cfn":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_heat'],
           }
    service { "openstack-heat-engine":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_ussuri::configure_heat'],
           }
           
 # Services for ceilometer
    #service { "openstack-ceilometer-api":
    #               ensure      => stopped,
    #               enable      => true,
    #               hasstatus   => true,
    #               hasrestart  => true,
    #               subscribe   => Class['controller_ussuri::configure_ceilometer'],
    #       }
    #service { "openstack-ceilometer-notification":
    #               ensure      => running,
    #               enable      => true,
    #               hasstatus   => true,
    #               hasrestart  => true,
    #               subscribe   => Class['controller_ussuri::configure_ceilometer'],
    #        }          
    #service { "openstack-ceilometer-central":
    #               ensure      => running,
    #               enable      => true,
    #               hasstatus   => true,
    #               hasrestart  => true,
    #               subscribe   => Class['controller_ussuri::configure_ceilometer'],
    #       }
    #service { "openstack-ceilometer-collector":
    #               ensure      => running,
    #               enable      => true,
    #               hasstatus   => true,
    #               hasrestart  => true,
    #               subscribe   => Class['controller_ussuri::configure_ceilometer'],
    #       }

  }

class compute_train::service inherits compute_train::params {
#include compute_train::params

# Services needed

       Service["openvswitch"] -> Exec['create_bridge']

       service { "openvswitch":
                        ensure      => running,
                        enable      => true,
                        hasstatus   => true,
                        hasrestart  => true,
                        require     => Package["openstack-neutron-openvswitch"],
               }

       service { "neutron-openvswitch-agent":
                        ensure      => running,
                        enable      => true,
                        hasstatus   => true,
                        hasrestart  => true,
                        require     => Package["openstack-neutron-openvswitch"],
                        subscribe   => Class['compute_train::neutron'],
               }
       
       service { "neutron-ovs-cleanup":
                        enable      => true,
                        require     => Package["openstack-neutron-openvswitch"],
               }

       service { "messagebus":
                     ensure      => running,
                     enable      => true,
                     hasstatus   => true,
                     hasrestart  => true,
                     require     => Package["libvirt"],
               }


       service { "openstack-nova-compute":
                    ensure      => running,
                    enable      => true,
                    hasstatus   => true,
                    hasrestart  => true,
                    require     => Package["openstack-nova-compute"],
                    subscribe   => Class['compute_train::nova']
               }

       service { "polkit":
                    ensure      => running,
                    enable      => true,
                    hasstatus   => true,
                    hasrestart  => true,
                    subscribe   => Class['compute_train::nova']

               }
        

        exec { 'create_bridge':
                     command     => "/usr/bin/ovs-vsctl add-br br-int",
                     unless      => "/usr/bin/ovs-vsctl br-exists br-int",
                     require     => Service["openvswitch"],
             }
                            

    if $::compute_train::cloud_role == "is_prod_localstorage" {

                  file { 'nova-instances':
                            path        => "/var/lib/nova/instances",
                            ensure      => directory,
                            require     => Package["openstack-nova-common"],
                       }
                             }

    if $::compute_train::cloud_role == "is_prod_sharedstorage" {
                  file { 'nova-instances':
                            path        => "/var/lib/nova/instances",
                            ensure      => directory,
                            require     => Package["openstack-nova-common"],
                       }
                       
                  # mount NFS file system
                  mount { "/var/lib/nova/instances":
                            ensure      => mounted,
                            device      => "192.168.61.100:volume-nova-prod",
                            atboot      => true,
                            fstype      => "nfs",
                            options     => "defaults"
                        }
    }

}

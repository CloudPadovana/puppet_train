class compute_train::stopservices inherits compute_train::params {

# Services needed
#systemctl stop openvswitch
#systemctl stop neutron-openvswitch-agent
#systemctl stop openstack-nova-compute
###
    
    #notify { 'stopservices': 
    #                    message => "sono in stop services"
    #       }
    service { "stop openvswitch service":
                        stop        => "/usr/bin/systemctl stop openvswitch",
                        require => Exec['checkForRelease'],
            }
    service { 'stop neutron-openvswitch-agent service':
                        stop        => "/usr/bin/systemctl stop neutron-openvswitch-agent",
                        require => Exec['checkForRelease'],
            }
    ## FF servizio chiesto da nova
    #service { 'stop libvirt service':
    #                    stop        => "/usr/bin/systemctl stop libvirtd.service",
    #                    require => Exec['checkForRelease'],
    #        }
    ##

    service { 'stop openstack-nova-compute service':
                        stop        => "/usr/bin/systemctl stop openstack-nova-compute",
                        require => Exec['checkForRelease'],
            }
    
    exec { 'checkForRelease':
       command => "/usr/bin/yum list installed | grep centos-release-openstack-rocky ; /usr/bin/echo $?",
       returns => "0",
       refreshonly => true,
    }
}

class compute_train::nova inherits compute_train::params {
#($compute_train::params::cloud_role) inherits compute_train::params {

#include compute_train::params
include compute_train::install

# $novapackages = [ "openstack-nova-compute",
#                     "openstack-nova-common" ]
# package { $novapackages: ensure => "installed" }



     file { '/etc/nova/nova.conf':
               ensure   => present,
               require    => Package["openstack-nova-common"],
          }


#     file { '/etc/nova/policy.json':
#               source      => 'puppet:///modules/compute_train/policy.json',
#               path        => '/etc/nova/policy.json',
#               backup      => true,
#          }
 

 define do_config ($conf_file, $section, $param, $value) {
           exec { "${name}":
                             command     => "/usr/bin/crudini --set ${conf_file} ${section} ${param} \"${value}\"",
                             require     => Package['crudini'],
                             unless      => "/usr/bin/crudini --get ${conf_file} ${section} ${param} 2>/dev/null | /bin/grep -- \"^${value}$\" 2>&1 >/dev/null",
                }
         }

   define remove_config ($conf_file, $section, $param, $value) {
           exec { "${name}":
                              command     => "/usr/bin/crudini --del ${conf_file} ${section} ${param}",
                              require     => Package['crudini'],
                              onlyif      => "/usr/bin/crudini --get ${conf_file} ${section} ${param} 2>/dev/null | /bin/grep -- \"^${value}$\" 2>&1 >/dev/null",
                }
        }

define do_augeas_config ($conf_file, $section, $param) {
    $split = split($name, '~')
    $value = $split[-1]
    $index = $split[-2]

    augeas { "augeas/${conf_file}/${section}/${param}/${index}/${name}":
          lens    => "PythonPaste.lns",
          incl    => $conf_file,
          changes => [ "set ${section}/${param}[${index}] ${value}" ],
          onlyif  => "get ${section}/${param}[${index}] != ${value}"
        }
}


define do_config_list ($conf_file, $section, $param, $values) {
    $values_size = size($values)

    # remove the entire block if the size doesn't match
    augeas { "remove_${conf_file}_${section}_${param}":
          lens    => "PythonPaste.lns",
          incl    => $conf_file,
          changes => [ "rm ${section}/${param}" ],
          onlyif  => "match ${section}/${param} size > ${values_size}"
    }

    $namevars = array_to_namevars($values, "${conf_file}~${section}~${param}", "~")

    # check each value
    compute_train::nova::do_augeas_config { $namevars:
             conf_file => $conf_file,
             section => $section,
             param => $param
    }
}

        
#
# nova.conf
#

  compute_train::nova::do_config { 'nova_enabled_apis': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'enabled_apis', value => $compute_train::params::nova_enabled_apis, }
  compute_train::nova::do_config { 'nova_transport_url': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'transport_url', value => $compute_train::params::transport_url, }
  compute_train::nova::do_config { 'nova_auth_strategy': conf_file => '/etc/nova/nova.conf', section => 'api', param => 'auth_strategy', value => $compute_train::params::auth_strategy, }

####
  compute_train::nova::do_config { 'nova_use_neutron': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'use_neutron', value => $compute_train::params::nova_use_neutron}
  compute_train::nova::do_config { 'nova_my_ip': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'my_ip', value => $compute_train::params::my_ip, }
  ### FF DEPRECATED in PIKE firewall_driver
  ### MS: Ma la documentazione dice di settarlo            
  compute_train::nova::do_config { 'nova_firewall_driver': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'firewall_driver', value => $compute_train::params::nova_firewall_driver, }
  ###

######
  compute_train::nova::do_config { 'nova_cpu_allocation_ratio': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'cpu_allocation_ratio', value => $compute_train::params::cpu_allocation_ratio, }
  compute_train::nova::do_config { 'nova_ram_allocation_ratio': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'ram_allocation_ratio', value => $compute_train::params::ram_allocation_ratio, }
  compute_train::nova::do_config { 'nova_disk_allocation_ratio': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'disk_allocation_ratio', value => $compute_train::params::disk_allocation_ratio, }
  compute_train::nova::do_config { 'nova_allow_resize': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'allow_resize_to_same_host', value => $compute_train::params::allow_resize, }
  compute_train::nova::do_config { 'nova_auth_type': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'auth_type', value => $compute_train::params::auth_type}
  compute_train::nova::do_config { 'nova_project_domain_name': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'project_domain_name', value => $compute_train::params::project_domain_name, }
  compute_train::nova::do_config { 'nova_user_domain_name': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'user_domain_name', value => $compute_train::params::user_domain_name, }
  ## FF da queens cambiano porte da 35357 a 5000 
  #compute_train::nova::do_config { 'nova_authuri': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'auth_uri', value => $compute_train::params::auth_uri, }
  compute_train::nova::do_config { 'nova_keystone_authtoken_auth_url': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'auth_url', value => $compute_train::params::nova_keystone_authtoken_auth_url, }
  ##
  compute_train::nova::do_config { 'nova_keystone_authtoken_memcached_servers': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'memcached_servers', value => $compute_train::params::memcached_servers, }
  compute_train::nova::do_config { 'nova_project_name': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'project_name', value => $compute_train::params::project_name, }
  compute_train::nova::do_config { 'nova_username': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'username', value => $compute_train::params::nova_username, }
  compute_train::nova::do_config { 'nova_password': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'password', value => $compute_train::params::nova_password, }
  compute_train::nova::do_config { 'nova_cafile': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'cafile', value => $compute_train::params::cafile, }

  compute_train::nova::do_config { 'nova_vnc_enabled': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'enabled', value => $compute_train::params::vnc_enabled, }
  ### FF MODIFIED IN QUEENS [vnc]vncserver_listen --> [vnc]server_listen and [vnc]vncserver_proxyclient_address -->w [vnc]server_proxyclient_address
  #compute_train::nova::do_config { 'nova_vncserver_listen': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'vncserver_listen', value => $compute_ocata::params::vncserver_listen, }
  #compute_train::nova::do_config { 'nova_vncserver_proxy': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'vncserver_proxyclient_address', value => $compute_ocata::params::my_ip, }
  compute_train::nova::do_config { 'nova_vnc_server_listen': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'server_listen', value => $compute_train::params::vnc_server_listen, }
  compute_train::nova::do_config { 'nova_vnc_server_proxyclient_address': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'server_proxyclient_address', value => $compute_train::params::my_ip, }
  ###
  compute_train::nova::do_config { 'nova_novncproxy': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'novncproxy_base_url', value => $compute_train::params::novncproxy_base_url, }

  compute_train::nova::do_config { 'nova_glance': conf_file => '/etc/nova/nova.conf', section => 'glance', param => 'api_servers', value => $compute_train::params::glance_api_servers, }

  compute_train::nova::do_config { 'nova_lock_path': conf_file => '/etc/nova/nova.conf', section => 'oslo_concurrency', param => 'lock_path', value => $compute_train::params::nova_lock_path, }
#############
  ### FF DEPRECATED in QUEENS os_region_name --> region_name
  #compute_train::nova::do_config { 'nova_placement_os_region_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'os_region_name', value => $compute_ocata::params::region_name, }
  compute_train::nova::do_config { 'nova_placement_region_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'region_name', value => $compute_train::params::region_name, }
  ###
  compute_train::nova::do_config { 'nova_placement_project_domain_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'project_domain_name', value => $compute_train::params::project_domain_name, }
  compute_train::nova::do_config { 'nova_placement_project_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'project_name', value => $compute_train::params::project_name, }
  compute_train::nova::do_config { 'nova_placement_auth_type': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'auth_type', value => $compute_train::params::auth_type, }
  compute_train::nova::do_config { 'nova_placement_user_domain_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'user_domain_name', value => $compute_train::params::user_domain_name, }
  ## FF cambia porta da 35357 a 5000
  compute_train::nova::do_config { 'nova_placement_auth_url': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'auth_url', value => $compute_train::params::nova_placement_auth_url, }
  ##
  compute_train::nova::do_config { 'nova_placement_username': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'username', value => $compute_train::params::placement_username, }
  compute_train::nova::do_config { 'nova_placement_password': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'password', value => $compute_train::params::placement_password, }
  compute_train::nova::do_config { 'nova_placement_cafile': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'cafile', value => $compute_train::params::cafile, }
  ### FF ADDED IN PIKE
  #The Placement API can be set to connect to a specific keystone endpoint interface using the os_interface option in the [placement] section inside nova.conf. This value is not required but can be used if a non-default endpoint interface is desired for connecting to the Placement service. By default, keystoneauth will connect to the “public” endpoint.
  ### DEPRECATED IN QUEEN [PLACEMENT]os_interface --> [PLACEMENT]valid_interfaces
  ###
  ## FF in rocky [neutron] auth_url passa da porta 35357 a 5000
  compute_train::nova::do_config { 'nova_neutron_auth_url': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'auth_url', value => $compute_train::params::neutron_auth_url, }
  compute_train::nova::do_config { 'nova_neutron_auth_type': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'auth_type', value => $compute_train::params::auth_type, }
  compute_train::nova::do_config { 'nova_neutron_project_domain_name': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'project_domain_name', value => $compute_train::params::project_domain_name, }
  compute_train::nova::do_config { 'nova_neutron_user_domain_name': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'user_domain_name', value => $compute_train::params::user_domain_name, }
  compute_train::nova::do_config { 'nova_neutron_region_name': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'region_name', value => $compute_train::params::region_name, }
  compute_train::nova::do_config { 'nova_neutron_project_name': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'project_name', value => $compute_train::params::project_name, }
  compute_train::nova::do_config { 'nova_neutron_username': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'username', value => $compute_train::params::neutron_username, }
  compute_train::nova::do_config { 'nova_neutron_password': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'password', value => $compute_train::params::neutron_password, }
  ### FF DEPRECATED in ROCKY [neutron]url --> [neutron]endpoint_override
  # compute_train::nova::do_config { 'nova_neutron_url': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'url', value => $compute_ocata::params::neutron_url, }
  compute_train::nova::do_config { 'nova_neutron_endpoint_override': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'endpoint_override', value => $compute_train::params::neutron_endpoint_override, }
  ###
  compute_train::nova::do_config { 'nova_neutron_cafile': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'cafile', value => $compute_train::params::cafile, }
  compute_train::nova::do_config { 'nova_libvirt_inject_pass': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'inject_password', value => $compute_train::params::libvirt_inject_pass, }
  compute_train::nova::do_config { 'nova_libvirt_inject_key': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'inject_key', value => $compute_train::params::libvirt_inject_key, }
  compute_train::nova::do_config { 'nova_libvirt_inject_part': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'inject_partition', value => $compute_train::params::libvirt_inject_part, }

  # IN QUEENS on AArch64 architecture cpu_mode for libvirt is set to host-passthrough by default ### 
  compute_train::nova::do_config { 'nova_libvirt_cpu_mode': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'cpu_mode', value => $compute_train::params::libvirt_cpu_mode, }

####config di libvirt per utilizzare ceph
  compute_train::nova::do_config { 'nova_libvirt_rbd_user': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'rbd_user', value => $compute_train::params::libvirt_rbd_user, }
  compute_train::nova::do_config { 'nova_libvirt_rbd_secret_uuid': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'rbd_secret_uuid', value => $compute_train::params::libvirt_rbd_secret_uuid, }

  compute_train::nova::do_config { 'nova_cinder_ssl_ca_file': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'ssl_ca_file', value => $compute_train::params::cafile, }
  compute_train::nova::do_config { 'nova_cinder_cafile': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'cafile', value => $compute_train::params::cafile, }
  compute_train::nova::do_config { 'nova_cinder_endpoint_template': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'endpoint_template', value => $compute_train::params::endpoint_template, }
  compute_train::nova::do_config { 'nova_cinder_os_region_name': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'os_region_name', value => $compute_train::params::region_name, }
  compute_train::nova::do_config { 'nova_cinder_auth_url': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'auth_url', value => $compute_train::params::cinder_keystone_auth_url, }
  compute_train::nova::do_config { 'nova_cinder_auth_type': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'auth_type', value => $compute_train::params::auth_type, }
  compute_train::nova::do_config { 'nova_cinder_project_domain_name': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'project_domain_name', value => $compute_train::params::project_domain_name, }
  compute_train::nova::do_config { 'nova_cinder_user_domain_name': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'user_domain_name', value => $compute_train::params::user_domain_name, }
  compute_train::nova::do_config { 'nova_cinder_region_name': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'region_name', value => $compute_train::params::region_name, }
  compute_train::nova::do_config { 'nova_cinder_project_name': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'project_name', value => $compute_train::params::project_name, }
  compute_train::nova::do_config { 'nova_cinder_username': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'username', value => $compute_train::params::cinder_username, }
  compute_train::nova::do_config { 'nova_cinder_password': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'password', value => $compute_train::params::cinder_password, }



#### per https nel compute non dovrebbe servire
compute_train::nova::do_config { 'nova_enable_proxy_headers_parsing': conf_file => '/etc/nova/nova.conf', section => 'oslo_middleware', param => 'enable_proxy_headers_parsing', value => $compute_train::params::enable_proxy_headers_parsing, }

######
#
# nova.conf for Ceilometer
#
  compute_train::nova::do_config { 'nova_instance_usage_audit': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'instance_usage_audit', value => $compute_train::params::nova_instance_usage_audit, }
  compute_train::nova::do_config { 'nova_instance_usage_audit_period': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'instance_usage_audit_period', value => $compute_train::params::nova_instance_usage_audit_period, }

# We don't use anymore ceilometer              
#              compute_train::nova::do_config { 'nova_notify_on_state_change': conf_file => '/etc/nova/nova.conf', section => 'notifications', param => 'notify_on_state_change', value => $compute_train::params::nova_notify_on_state_change, }
#  compute_train::nova::do_config { 'nova_notification_driver': conf_file => '/etc/nova/nova.conf', section => 'oslo_messaging_notifications', param => 'driver', value => $compute_train::params::nova_notification_driver, }


   compute_train::nova::do_config { "nova_amqp_durable_queues":
           conf_file => '/etc/nova/nova.conf',
           section   => 'oslo_messaging_rabbit',
           param     => 'amqp_durable_queues',
           value    => $compute_train::params::amqp_durable_queues,
         }

   compute_train::nova::do_config { "nova_rabbit_ha_queues":
           conf_file => '/etc/nova/nova.conf',
           section   => 'oslo_messaging_rabbit',
           param     => 'rabbit_ha_queues',
           value    => $compute_train::params::rabbit_ha_queues, 
         }


# GPU specific setting and some setting for better performance for SSD disk for cld-dfa-gpu-01
 if ($::mgmtnw_ip == "192.168.60.107") {
  compute_train::nova::do_config { 'pci_passthrough_whitelist': conf_file => '/etc/nova/nova.conf', section => 'pci', param => 'passthrough_whitelist', value => $compute_train::params::pci_passthrough_whitelist, }

   compute_train::nova::do_config_list { "pci_alias":
           conf_file => '/etc/nova/nova.conf',
           section   => 'pci',
           param     => 'alias',
           values    => [ "$compute_train::params::pci_titanxp_VGA", "$compute_train::params::pci_titanxp_SND", "$compute_train::params::pci_quadro_VGA", "$compute_train::params::pci_quadro_Audio", "$compute_train::params::pci_quadro_USB", "$compute_train::params::pci_quadro_SerialBus", "$compute_train::params::pci_geforcegtx_VGA", "$compute_train::params::pci_geforcegtx_SND"  ],
           #values    => [ "$compute_train::params::pci_alias_1", "$compute_train::params::pci_alias_2" ],          
         }

   compute_train::nova::do_config_list { "preallocate_images":
           conf_file => '/etc/nova/nova.conf',
           section   => 'DEFAULT',
           param     => 'preallocate_images',
           values    => [ "$compute_train::params::nova_preallocate_images"   ],
         }
         
   
}

# GPU specific setting and some setting for better performance for SSD disk for cld-dfa-gpu-02
 if ($::mgmtnw_ip == "192.168.60.108") {
  compute_train::nova::do_config { 'pci_passthrough_whitelist': conf_file => '/etc/nova/nova.conf', section => 'pci', param => 'passthrough_whitelist', value => $compute_train::params::pci_passthrough_whitelist, }

   compute_train::nova::do_config_list { "pci_alias":
           conf_file => '/etc/nova/nova.conf',
           section   => 'pci',
           param     => 'alias',
           values    => [ "$compute_train::params::pci_t4"   ],
         }

   compute_train::nova::do_config_list { "preallocate_images":
           conf_file => '/etc/nova/nova.conf',
           section   => 'DEFAULT',
           param     => 'preallocate_images',
           values    => [ "$compute_train::params::nova_preallocate_images"   ],
         }
         
   
}

# GPU specific setting and some setting for better performance for SSD disk for cld-np-gpu-01
 if ($::mgmtnw_ip == "192.168.60.128") {
  compute_train::nova::do_config { 'pci_passthrough_whitelist': conf_file => '/etc/nova/nova.conf', section => 'pci', param => 'passthrough_whitelist', value => $compute_train::params::pci_passthrough_whitelist, }

   compute_train::nova::do_config_list { "pci_alias":
           conf_file => '/etc/nova/nova.conf',
           section   => 'pci',
           param     => 'alias',
           values    => [ "$compute_train::params::pci_v100"   ],
         }

   compute_train::nova::do_config_list { "preallocate_images":
           conf_file => '/etc/nova/nova.conf',
           section   => 'DEFAULT',
           param     => 'preallocate_images',
           values    => [ "$compute_train::params::nova_preallocate_images"   ],
         }
         
   
}



#####
# Config libvirt access role
#####

  file { '49-org.libvirt.unix.manager.rules':
           source      => 'puppet:///modules/compute_train/49-org.libvirt.unix.manager.rules',
           path        => '/etc/polkit-1/rules.d/49-org.libvirt.unix.manager.rules',
           ensure      => present,
           backup      => true,
           owner   => root,
           group   => root,
           mode    => "0644",
  }

}

class compute_ussuri::nova inherits compute_ussuri::params {
#($compute_ussuri::params::cloud_role) inherits compute_ussuri::params {

#include compute_ussuri::params
include compute_ussuri::install

# $novapackages = [ "openstack-nova-compute",
#                     "openstack-nova-common" ]
# package { $novapackages: ensure => "installed" }



     file { '/etc/nova/nova.conf':
               ensure   => present,
               require    => Package["openstack-nova-common"],
          }


#     file { '/etc/nova/policy.json':
#               source      => 'puppet:///modules/compute_ussuri/policy.json',
#               path        => '/etc/nova/policy.json',
#               backup      => true,
#          }
 

 define do_config ($conf_file, $section, $param, $value) {
           exec { "${name}":
                             command     => "/usr/bin/openstack-config --set ${conf_file} ${section} ${param} \"${value}\"",
                             require     => Package['openstack-utils'],
                             unless      => "/usr/bin/openstack-config --get ${conf_file} ${section} ${param} 2>/dev/null | /bin/grep -- \"^${value}$\" 2>&1 >/dev/null",
                }
         }

   define remove_config ($conf_file, $section, $param, $value) {
           exec { "${name}":
                              command     => "/usr/bin/openstack-config --del ${conf_file} ${section} ${param}",
                              require     => Package['openstack-utils'],
                              onlyif      => "/usr/bin/openstack-config --get ${conf_file} ${section} ${param} 2>/dev/null | /bin/grep -- \"^${value}$\" 2>&1 >/dev/null",
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
    compute_ussuri::nova::do_augeas_config { $namevars:
             conf_file => $conf_file,
             section => $section,
             param => $param
    }
}

        
#
# nova.conf
#

  compute_ussuri::nova::do_config { 'nova_enabled_apis': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'enabled_apis', value => $compute_ussuri::params::nova_enabled_apis, }
  compute_ussuri::nova::do_config { 'nova_transport_url': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'transport_url', value => $compute_ussuri::params::transport_url, }
  compute_ussuri::nova::do_config { 'nova_auth_strategy': conf_file => '/etc/nova/nova.conf', section => 'api', param => 'auth_strategy', value => $compute_ussuri::params::auth_strategy, }

####
  compute_ussuri::nova::do_config { 'nova_use_neutron': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'use_neutron', value => $compute_ussuri::params::nova_use_neutron}
  compute_ussuri::nova::do_config { 'nova_my_ip': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'my_ip', value => $compute_ussuri::params::my_ip, }
  ### FF DEPRECATED in PIKE firewall_driver
  ### MS: Ma la documentazione dice di settarlo            
  compute_ussuri::nova::do_config { 'nova_firewall_driver': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'firewall_driver', value => $compute_ussuri::params::nova_firewall_driver, }
  ###

######
  compute_ussuri::nova::do_config { 'nova_cpu_allocation_ratio': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'cpu_allocation_ratio', value => $compute_ussuri::params::cpu_allocation_ratio, }
  compute_ussuri::nova::do_config { 'nova_ram_allocation_ratio': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'ram_allocation_ratio', value => $compute_ussuri::params::ram_allocation_ratio, }
  compute_ussuri::nova::do_config { 'nova_disk_allocation_ratio': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'disk_allocation_ratio', value => $compute_ussuri::params::disk_allocation_ratio, }
  compute_ussuri::nova::do_config { 'nova_allow_resize': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'allow_resize_to_same_host', value => $compute_ussuri::params::allow_resize, }
  compute_ussuri::nova::do_config { 'nova_auth_type': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'auth_type', value => $compute_ussuri::params::auth_type}
  compute_ussuri::nova::do_config { 'nova_project_domain_name': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'project_domain_name', value => $compute_ussuri::params::project_domain_name, }
  compute_ussuri::nova::do_config { 'nova_user_domain_name': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'user_domain_name', value => $compute_ussuri::params::user_domain_name, }
  ## FF da queens cambiano porte da 35357 a 5000 
  #compute_ussuri::nova::do_config { 'nova_authuri': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'auth_uri', value => $compute_ussuri::params::auth_uri, }
  compute_ussuri::nova::do_config { 'nova_keystone_authtoken_auth_url': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'auth_url', value => $compute_ussuri::params::nova_keystone_authtoken_auth_url, }
  ##
  compute_ussuri::nova::do_config { 'nova_keystone_authtoken_memcached_servers': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'memcached_servers', value => $compute_ussuri::params::memcached_servers, }
  compute_ussuri::nova::do_config { 'nova_project_name': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'project_name', value => $compute_ussuri::params::project_name, }
  compute_ussuri::nova::do_config { 'nova_username': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'username', value => $compute_ussuri::params::nova_username, }
  compute_ussuri::nova::do_config { 'nova_password': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'password', value => $compute_ussuri::params::nova_password, }
  compute_ussuri::nova::do_config { 'nova_cafile': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'cafile', value => $compute_ussuri::params::cafile, }

  compute_ussuri::nova::do_config { 'nova_vnc_enabled': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'enabled', value => $compute_ussuri::params::vnc_enabled, }
  ### FF MODIFIED IN QUEENS [vnc]vncserver_listen --> [vnc]server_listen and [vnc]vncserver_proxyclient_address -->w [vnc]server_proxyclient_address
  #compute_ussuri::nova::do_config { 'nova_vncserver_listen': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'vncserver_listen', value => $compute_ocata::params::vncserver_listen, }
  #compute_ussuri::nova::do_config { 'nova_vncserver_proxy': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'vncserver_proxyclient_address', value => $compute_ocata::params::my_ip, }
  compute_ussuri::nova::do_config { 'nova_vnc_server_listen': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'server_listen', value => $compute_ussuri::params::vnc_server_listen, }
  compute_ussuri::nova::do_config { 'nova_vnc_server_proxyclient_address': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'server_proxyclient_address', value => $compute_ussuri::params::my_ip, }
  ###
  compute_ussuri::nova::do_config { 'nova_novncproxy': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'novncproxy_base_url', value => $compute_ussuri::params::novncproxy_base_url, }

  compute_ussuri::nova::do_config { 'nova_glance': conf_file => '/etc/nova/nova.conf', section => 'glance', param => 'api_servers', value => $compute_ussuri::params::glance_api_servers, }

  compute_ussuri::nova::do_config { 'nova_lock_path': conf_file => '/etc/nova/nova.conf', section => 'oslo_concurrency', param => 'lock_path', value => $compute_ussuri::params::nova_lock_path, }
#############
  ### FF DEPRECATED in QUEENS os_region_name --> region_name
  #compute_ussuri::nova::do_config { 'nova_placement_os_region_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'os_region_name', value => $compute_ocata::params::region_name, }
  compute_ussuri::nova::do_config { 'nova_placement_region_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'region_name', value => $compute_ussuri::params::region_name, }
  ###
  compute_ussuri::nova::do_config { 'nova_placement_project_domain_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'project_domain_name', value => $compute_ussuri::params::project_domain_name, }
  compute_ussuri::nova::do_config { 'nova_placement_project_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'project_name', value => $compute_ussuri::params::project_name, }
  compute_ussuri::nova::do_config { 'nova_placement_auth_type': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'auth_type', value => $compute_ussuri::params::auth_type, }
  compute_ussuri::nova::do_config { 'nova_placement_user_domain_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'user_domain_name', value => $compute_ussuri::params::user_domain_name, }
  ## FF cambia porta da 35357 a 5000
  compute_ussuri::nova::do_config { 'nova_placement_auth_url': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'auth_url', value => $compute_ussuri::params::nova_placement_auth_url, }
  ##
  compute_ussuri::nova::do_config { 'nova_placement_username': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'username', value => $compute_ussuri::params::placement_username, }
  compute_ussuri::nova::do_config { 'nova_placement_password': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'password', value => $compute_ussuri::params::placement_password, }
  compute_ussuri::nova::do_config { 'nova_placement_cafile': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'cafile', value => $compute_ussuri::params::cafile, }
  ### FF ADDED IN PIKE
  #The Placement API can be set to connect to a specific keystone endpoint interface using the os_interface option in the [placement] section inside nova.conf. This value is not required but can be used if a non-default endpoint interface is desired for connecting to the Placement service. By default, keystoneauth will connect to the “public” endpoint.
  ### DEPRECATED IN QUEEN [PLACEMENT]os_interface --> [PLACEMENT]valid_interfaces
  ###
  ## FF in rocky [neutron] auth_url passa da porta 35357 a 5000
  compute_ussuri::nova::do_config { 'nova_neutron_auth_url': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'auth_url', value => $compute_ussuri::params::neutron_auth_url, }
  compute_ussuri::nova::do_config { 'nova_neutron_auth_type': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'auth_type', value => $compute_ussuri::params::auth_type, }
  compute_ussuri::nova::do_config { 'nova_neutron_project_domain_name': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'project_domain_name', value => $compute_ussuri::params::project_domain_name, }
  compute_ussuri::nova::do_config { 'nova_neutron_user_domain_name': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'user_domain_name', value => $compute_ussuri::params::user_domain_name, }
  compute_ussuri::nova::do_config { 'nova_neutron_region_name': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'region_name', value => $compute_ussuri::params::region_name, }
  compute_ussuri::nova::do_config { 'nova_neutron_project_name': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'project_name', value => $compute_ussuri::params::project_name, }
  compute_ussuri::nova::do_config { 'nova_neutron_username': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'username', value => $compute_ussuri::params::neutron_username, }
  compute_ussuri::nova::do_config { 'nova_neutron_password': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'password', value => $compute_ussuri::params::neutron_password, }
  ### FF DEPRECATED in ROCKY [neutron]url --> [neutron]endpoint_override
  # compute_ussuri::nova::do_config { 'nova_neutron_url': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'url', value => $compute_ocata::params::neutron_url, }
  compute_ussuri::nova::do_config { 'nova_neutron_endpoint_override': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'endpoint_override', value => $compute_ussuri::params::neutron_endpoint_override, }
  ###
  compute_ussuri::nova::do_config { 'nova_neutron_cafile': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'cafile', value => $compute_ussuri::params::cafile, }
  compute_ussuri::nova::do_config { 'nova_libvirt_inject_pass': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'inject_password', value => $compute_ussuri::params::libvirt_inject_pass, }
  compute_ussuri::nova::do_config { 'nova_libvirt_inject_key': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'inject_key', value => $compute_ussuri::params::libvirt_inject_key, }
  compute_ussuri::nova::do_config { 'nova_libvirt_inject_part': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'inject_partition', value => $compute_ussuri::params::libvirt_inject_part, }

  # IN QUEENS on AArch64 architecture cpu_mode for libvirt is set to host-passthrough by default ### 
  compute_ussuri::nova::do_config { 'nova_libvirt_cpu_mode': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'cpu_mode', value => $compute_ussuri::params::libvirt_cpu_mode, }

####config di libvirt per utilizzare ceph
  compute_ussuri::nova::do_config { 'nova_libvirt_rbd_user': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'rbd_user', value => $compute_ussuri::params::libvirt_rbd_user, }
  compute_ussuri::nova::do_config { 'nova_libvirt_rbd_secret_uuid': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'rbd_secret_uuid', value => $compute_ussuri::params::libvirt_rbd_secret_uuid, }

  compute_ussuri::nova::do_config { 'nova_cinder_ssl_ca_file': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'ssl_ca_file', value => $compute_ussuri::params::cafile, }
  compute_ussuri::nova::do_config { 'nova_cinder_cafile': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'cafile', value => $compute_ussuri::params::cafile, }
  compute_ussuri::nova::do_config { 'nova_cinder_endpoint_template': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'endpoint_template', value => $compute_ussuri::params::endpoint_template, }
  compute_ussuri::nova::do_config { 'nova_cinder_os_region_name': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'os_region_name', value => $compute_ussuri::params::region_name, }

#### per https nel compute non dovrebbe servire
compute_ussuri::nova::do_config { 'nova_enable_proxy_headers_parsing': conf_file => '/etc/nova/nova.conf', section => 'oslo_middleware', param => 'enable_proxy_headers_parsing', value => $compute_ussuri::params::enable_proxy_headers_parsing, }

######
#
# nova.conf for Ceilometer
#
  compute_ussuri::nova::do_config { 'nova_instance_usage_audit': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'instance_usage_audit', value => $compute_ussuri::params::nova_instance_usage_audit, }
  compute_ussuri::nova::do_config { 'nova_instance_usage_audit_period': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'instance_usage_audit_period', value => $compute_ussuri::params::nova_instance_usage_audit_period, }

# We don't use anymore ceilometer              
#              compute_ussuri::nova::do_config { 'nova_notify_on_state_change': conf_file => '/etc/nova/nova.conf', section => 'notifications', param => 'notify_on_state_change', value => $compute_ussuri::params::nova_notify_on_state_change, }
#  compute_ussuri::nova::do_config { 'nova_notification_driver': conf_file => '/etc/nova/nova.conf', section => 'oslo_messaging_notifications', param => 'driver', value => $compute_ussuri::params::nova_notification_driver, }


# GPU specific setting and some setting for better performance for SSD disk for cld-dfa-gpu-01
 if ($::mgmt_ip == "192.168.60.107") {
  compute_ussuri::nova::do_config { 'pci_passthrough_whitelist': conf_file => '/etc/nova/nova.conf', section => 'pci', param => 'passthrough_whitelist', value => $compute_ussuri::params::pci_passthrough_whitelist, }

   compute_ussuri::nova::do_config_list { "pci_alias":
           conf_file => '/etc/nova/nova.conf',
           section   => 'pci',
           param     => 'alias',
           values    => [ "$compute_ussuri::params::pci_titanxp_VGA", "$compute_ussuri::params::pci_titanxp_SND", "$compute_ussuri::params::pci_quadro_VGA", "$compute_ussuri::params::pci_quadro_Audio", "$compute_ussuri::params::pci_quadro_USB", "$compute_ussuri::params::pci_quadro_SerialBus", "$compute_ussuri::params::pci_geforcegtx_VGA", "$compute_ussuri::params::pci_geforcegtx_SND"  ],
           #values    => [ "$compute_ussuri::params::pci_alias_1", "$compute_ussuri::params::pci_alias_2" ],          
         }

   compute_ussuri::nova::do_config_list { "preallocate_images":
           conf_file => '/etc/nova/nova.conf',
           section   => 'DEFAULT',
           param     => 'preallocate_images',
           values    => [ "$compute_ussuri::params::nova_preallocate_images"   ],
         }
         
   
}

# GPU specific setting and some setting for better performance for SSD disk for cld-dfa-gpu-02
 if ($::mgmt_ip == "192.168.60.108") {
  compute_ussuri::nova::do_config { 'pci_passthrough_whitelist': conf_file => '/etc/nova/nova.conf', section => 'pci', param => 'passthrough_whitelist', value => $compute_ussuri::params::pci_passthrough_whitelist, }

   compute_ussuri::nova::do_config_list { "pci_alias":
           conf_file => '/etc/nova/nova.conf',
           section   => 'pci',
           param     => 'alias',
           values    => [ "$compute_ussuri::params::pci_t4"   ],
         }

   compute_ussuri::nova::do_config_list { "preallocate_images":
           conf_file => '/etc/nova/nova.conf',
           section   => 'DEFAULT',
           param     => 'preallocate_images',
           values    => [ "$compute_ussuri::params::nova_preallocate_images"   ],
         }
         
   
}

# GPU specific setting and some setting for better performance for SSD disk for cld-np-gpu-01
 if ($::mgmt_ip == "192.168.60.128") {
  compute_ussuri::nova::do_config { 'pci_passthrough_whitelist': conf_file => '/etc/nova/nova.conf', section => 'pci', param => 'passthrough_whitelist', value => $compute_ussuri::params::pci_passthrough_whitelist, }

   compute_ussuri::nova::do_config_list { "pci_alias":
           conf_file => '/etc/nova/nova.conf',
           section   => 'pci',
           param     => 'alias',
           values    => [ "$compute_ussuri::params::pci_v100"   ],
         }

   compute_ussuri::nova::do_config_list { "preallocate_images":
           conf_file => '/etc/nova/nova.conf',
           section   => 'DEFAULT',
           param     => 'preallocate_images',
           values    => [ "$compute_ussuri::params::nova_preallocate_images"   ],
         }
         
   
}



#####
# Config libvirt access role
#####

  file { '49-org.libvirt.unix.manager.rules':
           source      => 'puppet:///modules/compute_ussuri/49-org.libvirt.unix.manager.rules',
           path        => '/etc/polkit-1/rules.d/49-org.libvirt.unix.manager.rules',
           ensure      => present,
           backup      => true,
           owner   => root,
           group   => root,
           mode    => "0644",
  }

}

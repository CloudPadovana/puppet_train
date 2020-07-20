class controller_train::configure_nova inherits controller_train::params {

#
# Questa classe:
# - popola il file /etc/nova/nova.conf
# - crea il file /etc/nova/policy.json in modo che solo l'owner di una VM possa farne lo stop e delete
# - crea il file /etc/nova/vendor-data.json (solo cloud di produzione) 
# 
###################  
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
    controller_train::configure_nova::do_augeas_config { $namevars:
            conf_file => $conf_file,
            section => $section,
            param => $param
              }
    }
              

       
# nova.conf
   controller_train::configure_nova::do_config { 'nova_auth_strategy': conf_file => '/etc/nova/nova.conf', section => 'api', param => 'auth_strategy', value => $controller_train::params::auth_strategy, }

   # MS for vendordata
   if $::controller_train::cloud_role == "is_production" {
       controller_train::configure_nova::do_config { 'nova_vendordata_providers': conf_file => '/etc/nova/nova.conf', section => 'api', param => 'vendordata_providers', value => $controller_train::params::nova_vendordata_providers, }
       controller_train::configure_nova::do_config { 'nova_vendordata_jsonfile_path': conf_file => '/etc/nova/nova.conf', section => 'api', param => 'vendordata_jsonfile_path', value => $controller_train::params::nova_vendordata_jsonfile_path, }
   }
   ###

   controller_train::configure_nova::do_config { 'nova_transport_url': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'transport_url', value => $controller_train::params::transport_url, }
   controller_train::configure_nova::do_config { 'nova_my_ip': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'my_ip', value => $controller_train::params::vip_mgmt, }
   ### FF DEPRECATED in PIKE firewall_driver
   ### MS: in realta` pero` la guida di installazione dice di metterlo.
   controller_train::configure_nova::do_config { 'nova_firewall_driver': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'firewall_driver', value => $controller_train::params::nova_firewall_driver, }
   ###
   controller_train::configure_nova::do_config { 'nova_use_neutron': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'use_neutron', value => $controller_train::params::use_neutron, }
   controller_train::configure_nova::do_config { 'nova_cpu_allocation_ratio': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'cpu_allocation_ratio', value => $controller_train::params::nova_cpu_allocation_ratio, }
   controller_train::configure_nova::do_config { 'nova_disk_allocation_ratio': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'disk_allocation_ratio', value => $controller_train::params::nova_disk_allocation_ratio, }
   controller_train::configure_nova::do_config { 'nova_ram_allocation_ratio': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'ram_allocation_ratio', value => $controller_train::params::nova_ram_allocation_ratio, }
   controller_train::configure_nova::do_config { 'nova_allow_resize': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'allow_resize_to_same_host', value => $controller_train::params::allow_resize, }
   controller_train::configure_nova::do_config { 'nova_enabled_filters': conf_file => '/etc/nova/nova.conf', section => 'filter_scheduler', param => 'enabled_filters', value => $controller_train::params::enabled_filters, }
   controller_train::configure_nova::do_config { 'nova_default_schedule_zone': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'default_schedule_zone', value => $controller_train::params::nova_default_schedule_zone, }
   controller_train::configure_nova::do_config { 'nova_scheduler_max_attempts': conf_file => '/etc/nova/nova.conf', section => 'scheduler', param => 'max_attempts', value => $controller_train::params::nova_scheduler_max_attempts, }
   controller_train::configure_nova::do_config { 'nova_host_subset_size': conf_file => '/etc/nova/nova.conf', section => 'filter_scheduler', param => 'host_subset_size', value => $controller_train::params::nova_host_subset_size, }
   controller_train::configure_nova::do_config { 'nova_host_discover_hosts': conf_file => '/etc/nova/nova.conf', section => 'scheduler', param => 'discover_hosts_in_cells_interval', value => $controller_train::params::nova_discover_hosts_in_cells_interval, }
   controller_train::configure_nova::do_config { 'nova_vnc_server_listen': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'server_listen', value => $controller_train::params::vip_pub, }
   controller_train::configure_nova::do_config { 'nova_vnc_server_proxyclient_address': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'server_proxyclient_address', value => $controller_train::params::vip_mgmt, }
   controller_train::configure_nova::do_config { 'nova_vnc_enabled': conf_file => '/etc/nova/nova.conf', section => 'vnc', param => 'enabled', value => $controller_train::params::vnc_enabled, }
   controller_train::configure_nova::do_config { 'nova_api_db': conf_file => '/etc/nova/nova.conf', section => 'api_database', param => 'connection', value => $controller_train::params::nova_api_db, }

   controller_train::configure_nova::do_config { 'nova_db': conf_file => '/etc/nova/nova.conf', section => 'database', param => 'connection', value => $controller_train::params::nova_db, }
   controller_train::configure_nova::do_config { 'nova_enabled_apis': conf_file => '/etc/nova/nova.conf', section => 'DEFAULT', param => 'enabled_apis', value => $controller_train::params::enabled_apis, }

   ## FF in train si deve creare il DB placement, con relativa connection url. Vanno spostati i dati
   #controller_train::configure_nova::do_config { 'nova_placement_db': conf_file => '/etc/nova/nova.conf', section => 'placement_database', param => 'connection', value => $controller_train::params::nova_placement_db, }
   ###

   controller_train::configure_nova::do_config { 'nova_oslo_lock_path': conf_file => '/etc/nova/nova.conf', section => 'oslo_concurrency', param => 'lock_path', value => $controller_train::params::nova_oslo_lock_path, }


   controller_train::configure_nova::do_config { 'nova_www_authenticate_uri': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'www_authenticate_uri', value => $controller_train::params::www_authenticate_uri, }
   controller_train::configure_nova::do_config { 'nova_memcached_servers': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'memcached_servers', value => $controller_train::params::memcached_servers, }
   controller_train::configure_nova::do_config { 'nova_keystone_authtoken_auth_url': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'auth_url', value => $controller_train::params::nova_keystone_authtoken_auth_url, }  
   controller_train::configure_nova::do_config { 'nova_auth_plugin': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'auth_type', value => $controller_train::params::auth_type, }
   controller_train::configure_nova::do_config { 'nova_project_domain_name': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'project_domain_name', value => $controller_train::params::project_domain_name, }
   controller_train::configure_nova::do_config { 'nova_user_domain_name': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'user_domain_name', value => $controller_train::params::user_domain_name, }
   controller_train::configure_nova::do_config { 'nova_project_name': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'project_name', value => $controller_train::params::project_name, }
   controller_train::configure_nova::do_config { 'nova_username': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'username', value => $controller_train::params::nova_username, }
   controller_train::configure_nova::do_config { 'nova_password': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'password', value => $controller_train::params::nova_password, }
   controller_train::configure_nova::do_config { 'nova_cafile': conf_file => '/etc/nova/nova.conf', section => 'keystone_authtoken', param => 'cafile', value => $controller_train::params::cafile, }

   controller_train::configure_nova::do_config { 'nova_inject_password': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'inject_password', value => $controller_train::params::nova_inject_password, }
   controller_train::configure_nova::do_config { 'nova_inject_key': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'inject_key', value => $controller_train::params::nova_inject_key, }
   controller_train::configure_nova::do_config { 'nova_inject_partition': conf_file => '/etc/nova/nova.conf', section => 'libvirt', param => 'inject_partition', value => $controller_train::params::nova_inject_partition, }
   controller_train::configure_nova::do_config { 'nova_glance_api_servers': conf_file => '/etc/nova/nova.conf', section => 'glance', param => 'api_servers', value => $controller_train::params::glance_api_servers, }
   controller_train::configure_nova::do_config { 'nova_neutron_endpoint_override': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'endpoint_override', value => $controller_train::params::neutron_endpoint_override, }
   controller_train::configure_nova::do_config { 'nova_neutron_auth_type': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'auth_type', value => $controller_train::params::auth_type, }
   controller_train::configure_nova::do_config { 'nova_neutron_auth_url': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'auth_url', value => $controller_train::params::neutron_auth_url, }
   controller_train::configure_nova::do_config { 'nova_neutron_project_domain_name': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'project_domain_name', value => $controller_train::params::project_domain_name, }
   controller_train::configure_nova::do_config { 'nova_neutron_user_domain_name': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'user_domain_name', value => $controller_train::params::user_domain_name, }
   controller_train::configure_nova::do_config { 'nova_neutron_region_name': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'region_name', value => $controller_train::params::region_name, }
   controller_train::configure_nova::do_config { 'nova_neutron_project_name': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'project_name', value => $controller_train::params::project_name, }
   controller_train::configure_nova::do_config { 'nova_neutron_username': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'username', value => $controller_train::params::neutron_username, }
   controller_train::configure_nova::do_config { 'nova_neutron_password': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'password', value => $controller_train::params::neutron_password, }
   controller_train::configure_nova::do_config { 'nova_neutron_cafile': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'cafile', value => $controller_train::params::cafile, }
   controller_train::configure_nova::do_config { 'nova_service_metadata_proxy': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'service_metadata_proxy', value => $controller_train::params::service_metadata_proxy, }
   controller_train::configure_nova::do_config { 'nova_metadata_proxy_shared_secret': conf_file => '/etc/nova/nova.conf', section => 'neutron', param => 'metadata_proxy_shared_secret', value => $controller_train::params::metadata_proxy_shared_secret, }

   controller_train::configure_nova::do_config { 'nova_placement_auth_type': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'auth_type', value => $controller_train::params::auth_type, }
   controller_train::configure_nova::do_config { 'nova_placement_auth_url': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'auth_url', value => $controller_train::params::nova_placement_auth_url, }
   controller_train::configure_nova::do_config { 'nova_placement_project_domain_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'project_domain_name', value => $controller_train::params::project_domain_name, }
   controller_train::configure_nova::do_config { 'nova_placement_user_domain_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'user_domain_name', value => $controller_train::params::user_domain_name, }
   controller_train::configure_nova::do_config { 'nova_placement_region_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'region_name', value => $controller_train::params::region_name, }
   controller_train::configure_nova::do_config { 'nova_placement_project_name': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'project_name', value => $controller_train::params::project_name, }
   controller_train::configure_nova::do_config { 'nova_placement_username': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'username', value => $controller_train::params::placement_username, }
   controller_train::configure_nova::do_config { 'nova_placement_password': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'password', value => $controller_train::params::placement_password, }
   controller_train::configure_nova::do_config { 'nova_placement_cafile': conf_file => '/etc/nova/nova.conf', section => 'placement', param => 'cafile', value => $controller_train::params::cafile, }
  controller_train::configure_nova::do_config { 'nova_cinder_catalog_info': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'catalog_info', value => $controller_train::params::nova_cinder_catalog_info, }
  controller_train::configure_nova::do_config { 'nova_cinder_endpoint_template': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'endpoint_template', value => $controller_train::params::nova_cinder_endpoint_template, }
  controller_train::configure_nova::do_config { 'nova_cinder_os_region_name': conf_file => '/etc/nova/nova.conf', section => 'cinder', param => 'os_region_name', value => $controller_train::params::region_name, }
#######Proxy headers parsing
  controller_train::configure_nova::do_config { 'nova_enable_proxy_headers_parsing': conf_file => '/etc/nova/nova.conf', section => 'oslo_middleware', param => 'enable_proxy_headers_parsing', value => $controller_train::params::enable_proxy_headers_parsing, }

  controller_train::configure_nova::do_config_list { "nova_pci_alias": conf_file => '/etc/nova/nova.conf', section => 'pci', param => 'alias', values => [ "$controller_train::params::pci_titanxp_VGA", "$controller_train::params::pci_titanxp_SND", "$controller_train::params::pci_quadro_VGA", "$controller_train::params::pci_quadro_Audio", "$controller_train::params::pci_quadro_USB", "$controller_train::params::pci_quadro_SerialBus", "$controller_train::params::pci_geforcegtx_VGA", "$controller_train::params::pci_geforcegtx_SND","$controller_train::params::pci_t4","$controller_train::params::pci_v100" ], }
  controller_train::configure_nova::do_config { 'nova_pci_passthrough_whitelist': conf_file => '/etc/nova/nova.conf', section => 'pci', param => 'passthrough_whitelist', value => $controller_train::params::pci_passthrough_whitelist, }



######nova_policy and 00-nova-placement are copied from /controller_train/files dir       
file {'nova_policy.json':
           source      => 'puppet:///modules/controller_train/nova_policy.json',
           path        => '/etc/nova/policy.json',
           backup      => true,
           owner   => root,
           group   => nova,
           mode    => "0640",

         }
## FF serviva in queen e rocky per correggere un baco      
#file {'00-nova-placement-api.conf':
#           source      => 'puppet:///modules/controller_train/00-nova-placement-api.conf',
#           path        => '/etc/httpd/conf.d/00-nova-placement-api.conf',
#           ensure      => present,
#           backup      => true,
#           mode        => "0640",
#         }
##

# MS for vendordata
if $::controller_train::cloud_role == "is_production" {
  file {'vendor-data.json':
           source      => 'puppet:///modules/controller_train/vendor-data-prod.json',
           path        => '/etc/nova/vendor-data.json',
           ensure      => present,
           backup      => true,
           owner       => root,
           group       => nova,
           mode        => "0640",
         }
}
###

 
}

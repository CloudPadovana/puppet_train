class controller_ussuri::configure_neutron inherits controller_ussuri::params {

#
# Questa classe:
# - popola il file /etc/neutron/neutron.conf
# - popola il file /etc/neutron/plugins/ml2/ml2_conf.ini
# - popola il file  /etc/neutron/plugins/ml2/openvswitch_agent.ini
# - popola il file /etc/neutron/l3_agent.ini
# - popola il file /etc/neutron/dhcp_agent.ini
# - popola il file /etc/neutron/metadata_agent.ini
# - Definisce il link /etc/neutron/plugin.ini --> /etc/neutron/plugins/ml2/ml2_conf.ini
# - Modifica il file /etc/sudoers.d/neutron in modo che non venga loggato in /var/log/secure un msg ogni 2 sec
# 

  
 
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
                                                                                                                                             
  
# neutron.conf
   controller_ussuri::configure_neutron::do_config { 'neutron_transport_url': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'transport_url', value => $controller_ussuri::params::transport_url, }
   controller_ussuri::configure_neutron::do_config { 'neutron_auth_strategy': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'auth_strategy', value => $controller_ussuri::params::auth_strategy, }
   controller_ussuri::configure_neutron::do_config { 'neutron_core_plugin': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'core_plugin', value => $controller_ussuri::params::neutron_core_plugin, }
   controller_ussuri::configure_neutron::do_config { 'neutron_service_plugins': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'service_plugins', value => $controller_ussuri::params::neutron_service_plugins, }
   controller_ussuri::configure_neutron::do_config { 'neutron_allow_overlapping_ips': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'allow_overlapping_ips', value => $controller_ussuri::params::neutron_allow_overlapping_ips, }
   controller_ussuri::configure_neutron::do_config { 'neutron_notify_nova_on_port_status_changes': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'notify_nova_on_port_status_changes', value => $controller_ussuri::params::neutron_notify_nova_on_port_status_changes, }
   controller_ussuri::configure_neutron::do_config { 'neutron_notify_nova_on_port_data_changes': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'notify_nova_on_port_data_changes', value => $controller_ussuri::params::neutron_notify_nova_on_port_data_changes, }
   controller_ussuri::configure_neutron::do_config { 'neutron_dhcp_agents_per_network': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'dhcp_agents_per_network', value => $controller_ussuri::params::dhcp_agents_per_network, }
   controller_ussuri::configure_neutron::do_config { 'neutron_l3_ha': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'l3_ha', value => $controller_ussuri::params::neutron_l3_ha, }
   controller_ussuri::configure_neutron::do_config { 'neutron_allow_automatic_l3agent_failover': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'allow_automatic_l3agent_failover', value => $controller_ussuri::params::neutron_allow_automatic_l3agent_failover, }
   controller_ussuri::configure_neutron::do_config { 'neutron_max_l3_agents_per_router': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'max_l3_agents_per_router', value => $controller_ussuri::params::neutron_max_l3_agents_per_router, }
       
#MS: The min_l3_agents_per_router configuration option was deprecated in Newton cycle and removed in Ocata       
#   controller_ussuri::configure_neutron::do_config { 'neutron_min_l3_agents_per_router': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'min_l3_agents_per_router', value => $controller_ussuri::params::neutron_min_l3_agents_per_router, }
   controller_ussuri::configure_neutron::do_config { 'neutron_allow_automatic_dhcp_failover': conf_file => '/etc/neutron/neutron.conf', section => 'DEFAULT', param => 'allow_automatic_dhcp_failover', value => $controller_ussuri::params::allow_automatic_dhcp_failover, }

   controller_ussuri::configure_neutron::do_config { 'neutron_db': conf_file => '/etc/neutron/neutron.conf', section => 'database', param => 'connection', value => $controller_ussuri::params::neutron_db, }

       controller_ussuri::configure_neutron::do_config { 'neutron_lock_path': conf_file => '/etc/neutron/neutron.conf', section => 'oslo_concurrency', param => 'lock_path', value => $controller_ussuri::params::neutron_lock_path, }
   ##FF in rocky [keystone_authtoken] auth_uri diventa www_authenticate_uri
   #controller_ussuri::configure_neutron::do_config { 'neutron_auth_uri': conf_file => '/etc/neutron/neutron.conf', section => 'keystone_authtoken', param => 'auth_uri', value => $controller_ussuri::params::auth_uri, }   
   controller_ussuri::configure_neutron::do_config { 'neutron_www_authenticate_uri': conf_file => '/etc/neutron/neutron.conf', section => 'keystone_authtoken', param => 'www_authenticate_uri', value => $controller_ussuri::params::www_authenticate_uri, }   
   ##FF in rocky [keystone_authtoken] auth_url passa da 35357 a 5000
   controller_ussuri::configure_neutron::do_config { 'neutron_keystone_authtoken_auth_url': conf_file => '/etc/neutron/neutron.conf', section => 'keystone_authtoken', param => 'auth_url', value => $controller_ussuri::params::neutron_keystone_authtoken_auth_url, }
   controller_ussuri::configure_neutron::do_config { 'neutron_auth_type': conf_file => '/etc/neutron/neutron.conf', section => 'keystone_authtoken', param => 'auth_type', value => $controller_ussuri::params::auth_type, }
   controller_ussuri::configure_neutron::do_config { 'neutron_project_domain_name': conf_file => '/etc/neutron/neutron.conf', section => 'keystone_authtoken', param => 'project_domain_name', value => $controller_ussuri::params::project_domain_name, }
   controller_ussuri::configure_neutron::do_config { 'neutron_user_domain_name': conf_file => '/etc/neutron/neutron.conf', section => 'keystone_authtoken', param => 'user_domain_name', value => $controller_ussuri::params::user_domain_name, }
   controller_ussuri::configure_neutron::do_config { 'neutron_project_name': conf_file => '/etc/neutron/neutron.conf', section => 'keystone_authtoken', param => 'project_name', value => $controller_ussuri::params::project_name, }
   controller_ussuri::configure_neutron::do_config { 'neutron_username': conf_file => '/etc/neutron/neutron.conf', section => 'keystone_authtoken', param => 'username', value => $controller_ussuri::params::neutron_username, }
   controller_ussuri::configure_neutron::do_config { 'neutron_password': conf_file => '/etc/neutron/neutron.conf', section => 'keystone_authtoken', param => 'password', value => $controller_ussuri::params::neutron_password, }
   controller_ussuri::configure_neutron::do_config { 'neutron_cafile': conf_file => '/etc/neutron/neutron.conf', section => 'keystone_authtoken', param => 'cafile', value => $controller_ussuri::params::cafile, }
   controller_ussuri::configure_neutron::do_config { 'neutron_memcached_servers': conf_file => '/etc/neutron/neutron.conf', section => 'keystone_authtoken', param => 'memcached_servers', value => $controller_ussuri::params::memcached_servers, }

   ##FF in rocky [nova] auth_url da 35357 diventa 5000
   controller_ussuri::configure_neutron::do_config { 'neutron_nova_auth_url': conf_file => '/etc/neutron/neutron.conf', section => 'nova', param => 'auth_url', value => $controller_ussuri::params::neutron_auth_url, }
   controller_ussuri::configure_neutron::do_config { 'neutron_nova_auth_type': conf_file => '/etc/neutron/neutron.conf', section => 'nova', param => 'auth_type', value => $controller_ussuri::params::auth_type, }
   controller_ussuri::configure_neutron::do_config { 'neutron_nova_project_domain_name': conf_file => '/etc/neutron/neutron.conf', section => 'nova', param => 'project_domain_name', value => $controller_ussuri::params::project_domain_name, }
   controller_ussuri::configure_neutron::do_config { 'neutron_nova_user_domain_name': conf_file => '/etc/neutron/neutron.conf', section => 'nova', param => 'user_domain_name', value => $controller_ussuri::params::user_domain_name, }
   controller_ussuri::configure_neutron::do_config { 'neutron_nova_region_name': conf_file => '/etc/neutron/neutron.conf', section => 'nova', param => 'region_name', value => $controller_ussuri::params::region_name, }
   controller_ussuri::configure_neutron::do_config { 'neutron_nova_project_name': conf_file => '/etc/neutron/neutron.conf', section => 'nova', param => 'project_name', value => $controller_ussuri::params::project_name, }
   controller_ussuri::configure_neutron::do_config { 'neutron_nova_username': conf_file => '/etc/neutron/neutron.conf', section => 'nova', param => 'username', value => $controller_ussuri::params::nova_username, }
   controller_ussuri::configure_neutron::do_config { 'neutron_nova_password': conf_file => '/etc/neutron/neutron.conf', section => 'nova', param => 'password', value => $controller_ussuri::params::nova_password, }
   controller_ussuri::configure_neutron::do_config { 'neutron_nova_cafile': conf_file => '/etc/neutron/neutron.conf', section => 'nova', param => 'cafile', value => $controller_ussuri::params::cafile, }

#######Proxy headers parsing
controller_ussuri::configure_neutron::do_config { 'neutron_enable_proxy_headers_parsing': conf_file => '/etc/neutron/neutron.conf', section => 'oslo_middleware', param => 'enable_proxy_headers_parsing', value => $controller_ussuri::params::enable_proxy_headers_parsing, }


#
# Setting di quote di default per nuovi progetti, in modo da non dare la possibilita` di creare nuove reti, nuovi
# router
# Quota 0 per FIP
#
   controller_ussuri::configure_neutron::do_config { 'neutron_quota_network': conf_file => '/etc/neutron/neutron.conf', section => 'quotas', param => 'quota_network', value => $controller_ussuri::params::quota_network, }
   controller_ussuri::configure_neutron::do_config { 'neutron_quota_subnet': conf_file => '/etc/neutron/neutron.conf', section => 'quotas', param => 'quota_subnet', value => $controller_ussuri::params::quota_subnet, }
   controller_ussuri::configure_neutron::do_config { 'neutron_quota_port': conf_file => '/etc/neutron/neutron.conf', section => 'quotas', param => 'quota_port', value => $controller_ussuri::params::quota_port, }
   controller_ussuri::configure_neutron::do_config { 'neutron_quota_router': conf_file => '/etc/neutron/neutron.conf', section => 'quotas', param => 'quota_router', value => $controller_ussuri::params::quota_router, }
   controller_ussuri::configure_neutron::do_config { 'neutron_quota_floatingip': conf_file => '/etc/neutron/neutron.conf', section => 'quotas', param => 'quota_floatingip', value => $controller_ussuri::params::quota_floatingip, }


   # ml2_conf.ini

   controller_ussuri::configure_neutron::do_config { 'ml2_type_drivers': conf_file => '/etc/neutron/plugins/ml2/ml2_conf.ini', section => 'ml2', param => 'type_drivers', value => $controller_ussuri::params::ml2_type_drivers, }
   controller_ussuri::configure_neutron::do_config { 'ml2_tenant_network_types': conf_file => '/etc/neutron/plugins/ml2/ml2_conf.ini', section => 'ml2', param => 'tenant_network_types', value => $controller_ussuri::params::ml2_tenant_network_types, }
   controller_ussuri::configure_neutron::do_config { 'ml2_mechanism_drivers': conf_file => '/etc/neutron/plugins/ml2/ml2_conf.ini', section => 'ml2', param => 'mechanism_drivers', value => $controller_ussuri::params::ml2_mechanism_drivers, }

   controller_ussuri::configure_neutron::do_config { 'ml2_tunnel_id_ranges': conf_file => '/etc/neutron/plugins/ml2/ml2_conf.ini', section => 'ml2_type_gre', param => 'tunnel_id_ranges', value => $controller_ussuri::params::ml2_tunnel_id_ranges, }

   controller_ussuri::configure_neutron::do_config { 'ml2_tunnel_types': conf_file => '/etc/neutron/plugins/ml2/ml2_conf.ini', section => 'agent', param => 'tunnel_types', value => $controller_ussuri::params::ml2_tunnel_types, }

       controller_ussuri::configure_neutron::do_config { 'ml2_enable_security_group': conf_file => '/etc/neutron/plugins/ml2/ml2_conf.ini', section => 'securitygroup', param => 'enable_security_group', value => $controller_ussuri::params::ml2_enable_security_group, }
   controller_ussuri::configure_neutron::do_config { 'ml2_enable_ipset': conf_file => '/etc/neutron/plugins/ml2/ml2_conf.ini', section => 'securitygroup', param => 'enable_ipset', value => $controller_ussuri::params::ml2_enable_ipset, }

   controller_ussuri::configure_neutron::do_config { 'ml2_flat_networks': conf_file => '/etc/neutron/plugins/ml2/ml2_conf.ini', section => 'ml2_type_flat', param => 'flat_networks', value => $controller_ussuri::params::ml2_flat_networks, }

   controller_ussuri::configure_neutron::do_config { 'ml2_local_ip': conf_file => '/etc/neutron/plugins/ml2/ml2_conf.ini', section => 'ovs', param => 'local_ip', value => $controller_ussuri::params::ml2_local_ip, }
   controller_ussuri::configure_neutron::do_config { 'ml2_bridge_mappings': conf_file => '/etc/neutron/plugins/ml2/ml2_conf.ini', section => 'ovs', param => 'bridge_mappings', value => $controller_ussuri::params::ml2_bridge_mappings, }

   
   if $::controller_ussuri::cloud_role == "is_production" { 
     controller_ussuri::configure_neutron::do_config { 'ml2_network_vlan_ranges': conf_file => '/etc/neutron/plugins/ml2/ml2_conf.ini', section => 'ovs', param => 'network_vlan_ranges', value => $controller_ussuri::params::ml2_network_vlan_ranges, }
   }
              
  # openvswitch_agent.ini

   controller_ussuri::configure_neutron::do_config { 'ovs_tunnel_types': conf_file => '/etc/neutron/plugins/ml2/openvswitch_agent.ini', section => 'agent', param => 'tunnel_types', value => $controller_ussuri::params::ml2_tunnel_types, }
   controller_ussuri::configure_neutron::do_config { 'ovs_local_ip': conf_file => '/etc/neutron/plugins/ml2/openvswitch_agent.ini', section => 'ovs', param => 'local_ip', value => $controller_ussuri::params::ml2_local_ip, }
   ### FF ADDED in  PIKE: A new config option bridge_mac_table_size has been added for Neutron OVS agent. This value will be set on every Open vSwitch bridge managed by the openvswitch-neutron-agent in other_config:mac-table-size column in ovsdb. Default value for this new option is set to 50000 and it should be enough for most systems.
   ###
   controller_ussuri::configure_neutron::do_config { 'ovs_bridge_mappings': conf_file => '/etc/neutron/plugins/ml2/openvswitch_agent.ini', section => 'ovs', param => 'bridge_mappings', value => $controller_ussuri::params::ml2_bridge_mappings, }
   controller_ussuri::configure_neutron::do_config { 'ovs_enable_tunneling': conf_file => '/etc/neutron/plugins/ml2/openvswitch_agent.ini', section => 'ovs', param => 'enable_tunneling', value => $controller_ussuri::params::ovs_enable_tunneling, }
   # The following parameter was introduced after the powercut of Nov 2018. Without this parameter we had problems with
   # external networks
   ### FF DEPRECATED in PIKE of_interface Open vSwitch agent configuration option --> the current default driver (native) will be the only supported of_interface driver
   ## MS Ma senza abbiamo problemi di rete (forse perche` abbiamo piu` reti esterne ?)
   ## MS con la versione 13.0.3 non dovrebbe piu` servire. V. PDCL-1344
   ## controller_ussuri::configure_neutron::do_config { 'ovs_of_interface': conf_file => '/etc/neutron/plugins/ml2/openvswitch_agent.ini', section => 'ovs', param => 'of_interface', value => $controller_ussuri::params::ovs_of_interface, }
   ###
   controller_ussuri::configure_neutron::do_config { 'ovs_firewall_driver': conf_file => '/etc/neutron/plugins/ml2/openvswitch_agent.ini', section => 'securitygroup', param => 'firewall_driver', value => $controller_ussuri::params::ml2_firewall_driver, } 

# l3_agent.ini

   controller_ussuri::configure_neutron::do_config { 'l3_interface_driver': conf_file => '/etc/neutron/l3_agent.ini', section => 'DEFAULT', param => 'interface_driver', value => $controller_ussuri::params::interface_driver, }

   
   ### FF DEPRECATED in PIKE gateway_external_network_id --> external_network_bridge
   #controller_ussuri::configure_neutron::do_config { 'l3_gateway_external_network_id': conf_file => '/etc/neutron/l3_agent.ini', section => 'DEFAULT', param => 'gateway_external_network_id', value => $controller_ussuri::params::l3_gateway_external_network_id, }
   ## MS external_network_bridge reported as deprecated in the log file. Ma la documentazione dice di settarlo ...
   ##controller_ussuri::configure_neutron::do_config { 'l3_external_network_id': conf_file => '/etc/neutron/l3_agent.ini', section => 'DEFAULT', param => 'external_network_bridge', value => $controller_ussuri::params::l3_external_network_id, }
   controller_ussuri::configure_neutron::do_config { 'l3_external_network_bridge': conf_file => '/etc/neutron/l3_agent.ini', section => 'DEFAULT', param => 'external_network_bridge', value => $controller_ussuri::params::l3_external_network_bridge, }
   ###


# dhcp_agent.ini

  controller_ussuri::configure_neutron::do_config { 'dhcp_interface_driver': conf_file => '/etc/neutron/dhcp_agent.ini', section => 'DEFAULT', param => 'interface_driver', value => $controller_ussuri::params::interface_driver, }
  controller_ussuri::configure_neutron::do_config { 'dhcp_driver': conf_file => '/etc/neutron/dhcp_agent.ini', section => 'DEFAULT', param => 'dhcp_driver', value => $controller_ussuri::params::dhcp_driver, }

  if $::controller_ussuri::cloud_role == "is_test" {
      file { "$controller_ussuri::params::dnsmasq_config_file":
        ensure   => file,
        owner    => "root",
        group    => "neutron",
        mode     => "0644",
        content  => template("controller_ussuri/dnsmasq-neutron.conf.erb"),
    }
    controller_ussuri::configure_neutron::do_config { 'dnsmasq_config_file': 
      conf_file => '/etc/neutron/dhcp_agent.ini', 
      section => 'DEFAULT', 
      param => 'dnsmasq_config_file', 
      value => $controller_ussuri::params::dnsmasq_config_file,
    }
  }

# metadata_agent.ini
   controller_ussuri::configure_neutron::do_config { 'metadata_auth_ca_cert': conf_file => '/etc/neutron/metadata_agent.ini', section => 'DEFAULT', param => 'auth_ca_cert', value => $controller_ussuri::params::cafile, }
   ### FF DEPRECATED in PIKE nova_metadata_ip --> nova_metadata_host
   #controller_ussuri::configure_neutron::do_config { 'metadata_ip': conf_file => '/etc/neutron/metadata_agent.ini', section => 'DEFAULT', param => 'nova_metadata_ip', value => $controller_ussuri::params::vip_mgmt, }
   controller_ussuri::configure_neutron::do_config { 'metadata_ip': conf_file => '/etc/neutron/metadata_agent.ini', section => 'DEFAULT', param => 'nova_metadata_host', value => $controller_ussuri::params::vip_mgmt, }
   ###
   controller_ussuri::configure_neutron::do_config { 'metadata_metadata_proxy_shared_secret': conf_file => '/etc/neutron/metadata_agent.ini', section => 'DEFAULT', param => 'metadata_proxy_shared_secret', value => $controller_ussuri::params::metadata_proxy_shared_secret, }
  
################

  file {'/etc/neutron/plugin.ini':
              ensure      => link,
              target      => '/etc/neutron/plugins/ml2/ml2_conf.ini',
  }



  # Disable useless OVS loggin in secure file
  file_line { '/etc/sudoers.d/neutron  syslog':
           path   => '/etc/sudoers.d/neutron',
           line   => 'Defaults:neutron !requiretty, !syslog',
           match  => 'Defaults:neutron',
  }

}

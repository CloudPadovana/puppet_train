class controller_ussuri::configure_ec2 inherits controller_ussuri::params {

#
# Questa classe:
# - popola il file /etc/ec2api/ec2api.conf
# 
### FF da queens per i metadata deve modificare anche il file /etc/neutron/metadata_agent.ini


file { ['/var/lib/ec2-api',
       '/var/lib/ec2-api/tmp']:
      ensure => 'directory',
      owner  => 'ec2api',
      group  => 'ec2api',
      mode   => "0750",
    }

  
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
                                                                                                                                             

# ec2api.conf
   ## FF da queens in poi
   #controller_ussuri::configure_ec2::do_config { 'ec2_port': conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'ec2_port', value => $controller_ussuri::params::ec2_port, }
   #controller_ussuri::configure_ec2::do_config { 'ec2api_listen_port': conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'ec2api_listen_port', value => $controller_ussuri::params::ec2api_listen_port, }
   #controller_ussuri::configure_ec2::do_config { 'api_paste_config': conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'api_paste_config', value => $controller_ussuri::params::ec2_api_paste_config, }
   #controller_ussuri::configure_ec2::do_config { 'disable_ec2_classic': conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'disable_ec2_classic', value => $controller_ussuri::params::ec2_disable_ec2_classic, }
   #controller_ussuri::configure_ec2::do_config { 'nova_metadata_port': conf_file => '/etc/neutron/metadata_agent.ini', section => 'DEFAULT', param => 'nova_metadata_port', value => $controller_ussuri::params::ec2_nova_metadata_port, }
   #####
   controller_ussuri::configure_ec2::do_config { 'ec2_keystone_url': conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'keystone_url', value => $controller_ussuri::params::ec2_keystone_url, }
   controller_ussuri::configure_ec2::do_config { 'ec2_my_ip': conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'my_ip', value => $controller_ussuri::params::ec2_my_ip, }
   controller_ussuri::configure_ec2::do_config { 'ec2_external_network': conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'external_network', value => $controller_ussuri::params::ec2_external_network, }
   controller_ussuri::configure_ec2::do_config { 'ec2_ssl_ca_file': conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'ssl_ca_file', value => $controller_ussuri::params::cafile, }
   controller_ussuri::configure_ec2::do_config { 'ec2_log_file': conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'log_file', value => $controller_ussuri::params::ec2_log_file, }
# Problem with this parameter. Each time puppet runs: it resets it
       #   controller_ussuri::configure_ec2::do_config { 'ec2_logging_context_format_string': conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'logging_context_format_string', value => $controller_ussuri::params::ec2_logging_context_format_string, } 
   controller_ussuri::configure_ec2::do_config { 'ec2_cinder_service_type': conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'cinder_service_type', value => $controller_ussuri::params::ec2_cinder_service_type, } 
       controller_ussuri::configure_ec2::do_config { 'ec2_full_vpc_support': conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'full_vpc_support', value => $controller_ussuri::params::ec2_full_vpc_support, }
   controller_ussuri::configure_ec2::do_config { 'keystone_ec2_tokens_url':  conf_file => '/etc/ec2api/ec2api.conf', section => 'DEFAULT', param => 'keystone_ec2_tokens_url', value => "${controller_ussuri::params::ec2_keystone_url}/ec2tokens",}
   controller_ussuri::configure_ec2::do_config { 'ec2_db': conf_file => '/etc/ec2api/ec2api.conf', section => 'database', param => 'connection', value => $controller_ussuri::params::ec2_db, }
#   controller_ussuri::configure_ec2::do_config { 'ec2_auth_uri': conf_file => '/etc/ec2api/ec2api.conf', section => 'keystone_authtoken', param => 'auth_uri', value => $controller_ussuri::params::auth_url, }   
   controller_ussuri::configure_ec2::do_config { 'ec2_www_authenticate_uri': conf_file => '/etc/ec2api/ec2api.conf', section => 'keystone_authtoken', param => 'www_authenticate_uri', value => $controller_ussuri::params::www_authenticate_uri, }   
   controller_ussuri::configure_ec2::do_config { 'ec2_auth_url': conf_file => '/etc/ec2api/ec2api.conf', section => 'keystone_authtoken', param => 'auth_url', value => $controller_ussuri::params::ec2_keystone_url, }   
   controller_ussuri::configure_ec2::do_config { 'ec2_user': conf_file => '/etc/ec2api/ec2api.conf', section => 'keystone_authtoken', param => 'username', value => $controller_ussuri::params::ec2_user, }
   controller_ussuri::configure_ec2::do_config { 'ec2_password': conf_file => '/etc/ec2api/ec2api.conf', section => 'keystone_authtoken', param => 'password', value => $controller_ussuri::params::ec2_password, }
   controller_ussuri::configure_ec2::do_config { 'ec2_tenant_name': conf_file => '/etc/ec2api/ec2api.conf', section => 'keystone_authtoken', param => 'project_name', value => $controller_ussuri::params::project_name, }
   controller_ussuri::configure_ec2::do_config { 'ec2_project_domain_name': conf_file => '/etc/ec2api/ec2api.conf', section => 'keystone_authtoken', param => 'project_domain_name', value => $controller_ussuri::params::project_domain_name, }
   controller_ussuri::configure_ec2::do_config { 'ec2_user_domain_name': conf_file => '/etc/ec2api/ec2api.conf', section => 'keystone_authtoken', param => 'user_domain_name', value => $controller_ussuri::params::user_domain_name, }
   controller_ussuri::configure_ec2::do_config { 'ec2_auth_type': conf_file => '/etc/ec2api/ec2api.conf', section => 'keystone_authtoken', param => 'auth_type', value => $controller_ussuri::params::auth_type, }
   controller_ussuri::configure_ec2::do_config { 'ec2_cafile': conf_file => '/etc/ec2api/ec2api.conf', section => 'keystone_authtoken', param => 'cafile', value => $controller_ussuri::params::cafile, }
   controller_ussuri::configure_ec2::do_config { 'ec2_nova_metadata_ip': conf_file => '/etc/ec2api/ec2api.conf', section => 'metadata', param => 'nova_metadata_ip', value => $controller_ussuri::params::ec2_nova_metadata_ip, }
   controller_ussuri::configure_ec2::do_config { 'ec2_auth_ca_cert': conf_file => '/etc/ec2api/ec2api.conf', section => 'metadata', param => 'auth_ca_cert', value => $controller_ussuri::params::cafile, }

   controller_ussuri::configure_ec2::do_config { 'ec2_cache_backend': conf_file => '/etc/ec2api/ec2api.conf', section => 'cache', param => 'backend', value => $controller_ussuri::params::ec2_cache_backend, } 
   controller_ussuri::configure_ec2::do_config { 'ec2_cache_enabled': conf_file => '/etc/ec2api/ec2api.conf', section => 'cache', param => 'enabled', value => $controller_ussuri::params::ec2_cache_enabled, } 

   controller_ussuri::configure_ec2::do_config { 'ec2_lock_path': conf_file => '/etc/ec2api/ec2api.conf', section => 'oslo_concurrency', param => 'lock_path', value => $controller_ussuri::params::ec2_lock_path, } 

}

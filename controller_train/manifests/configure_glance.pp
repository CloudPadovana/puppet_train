class controller_train::configure_glance inherits controller_train::params {

#
# Questa classe:
# Crea la directory per node_staging_uri
# - popola il file /etc/glance/glance-api.conf
# - popola il file /etc/glance/glance-registry.conf
#   Crea il file /etc/glance/policy.json

# Changes wrt default:
# role:admi required for delete_image_location, get_image_location, set_image_location
# See https://wiki.openstack.org/wiki/OSSN/OSSN-0065

  
    file { "/etc/glance/policy.json":
            ensure   => file,
            owner    => "root",
            group    => "glance",
            mode     => "0640",
            source  => "puppet:///modules/controller_train/glance.policy.json",
          }
          
  

    file { $controller_train::params::glance_api_node_staging_path:
            ensure => 'directory',
            owner  => 'glance',
            group  => 'glance',
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
                                                                                                                                             
  


# glance-api.conf

#
# This was set in the past for ceilometer
#   controller_train::configure_glance::do_config { 'glance_api_notification_driver': conf_file => '/etc/glance/glance-api.conf', section => 'DEFAULT', param => 'notification_driver', value => $controller_train::params::glance_notification_driver, }

# v1 api was enabled in Ocata, otherwise euca-describe-images didn't work      
# v1 api removed in rocky
#  controller_train::configure_glance::do_config { 'glance_enable_v1_api': conf_file => '/etc/glance/glance-api.conf', section => 'DEFAULT', param => 'enable_v1_api', value => $controller_train::params::glance_enable_v1_api, }

# 25 GB max size for an image
  controller_train::configure_glance::do_config { 'glance_image_size_cap': conf_file => '/etc/glance/glance-api.conf', section => 'DEFAULT', param => 'image_size_cap', value => $controller_train::params::glance_image_size_cap, }

# registry_host is deprecated in Rocky
# As far as I (Massimo) understand, it was at any rate useless in our environment
#       controller_train::configure_glance::do_config { 'glance_api_registry_host': conf_file => '/etc/glance/glance-api.conf', section => 'DEFAULT', param => 'registry_host', value => $controller_train::params::vip_mgmt, }
#
# Not needed anymore since we have now a single backend (and this attribute is now deprecated)
#  controller_train::configure_glance::do_config { 'glance_api_show_multiple_locations': conf_file => '/etc/glance/glance-api.conf', section => 'DEFAULT', param => 'show_multiple_locations', value => $controller_train::params::glance_api_show_multiple_locations, }
  controller_train::configure_glance::do_config { 'glance_api_show_image_direct_url': conf_file => '/etc/glance/glance-api.conf', section => 'DEFAULT', param => 'show_image_direct_url', value => $controller_train::params::glance_api_show_image_direct_url, }
#
# parametro necessario per la nuova funzionalita' di interoperable image import
# deprecato in train. sostituito da filesystem_store_datadir
#  controller_train::configure_glance::do_config { 'glance_api_node_staging_uri': conf_file => '/etc/glance/glance-api.conf', section => 'DEFAULT', param => 'node_staging_uri', value => $controller_train::params::glance_api_node_staging_uri, }


# New ways in rocky to define glance backends       
# But this causes problems when adding location: revert to old mode
#       controller_train::configure_glance::do_config { 'glance_api_enabled_backends': conf_file => '/etc/glance/glance-api.conf', section => 'DEFAULT', param => 'enabled_backends', value => $controller_train::params::glance_api_enabled_backends, }
# In train we try to enable glance backends again
  controller_train::configure_glance::do_config { 'glance_api_enabled_backends': conf_file => '/etc/glance/glance-api.conf', section => 'DEFAULT', param => 'enabled_backends', value => $controller_train::params::glance_api_enabled_backends, }
# In train we start to configure reserved stores
  controller_train::configure_glance::do_config { 'glance_api_filesystem_store_datadir': conf_file => '/etc/glance/glance-api.conf', section => 'os_glance_staging_store', param => 'filesystem_store_datadir', value => $controller_train::params::glance_api_filesystem_store_datadir, }


  controller_train::configure_glance::do_config { 'glance_api_db': conf_file => '/etc/glance/glance-api.conf', section => 'database', param => 'connection', value => $controller_train::params::glance_db, }

       
  # FF in queens auth_uri ed auth_url sono sulla porta 5000 per glance
  # FF in rocky [keystone_authtoken] auth_uri diventa www_authenticate_uri
  controller_train::configure_glance::do_config { 'glance_api_www_authenticate_uri': conf_file => '/etc/glance/glance-api.conf', section => 'keystone_authtoken', param => 'www_authenticate_uri', value => $controller_train::params::www_authenticate_uri, }
  controller_train::configure_glance::do_config { 'glance_api_auth_url': conf_file => '/etc/glance/glance-api.conf', section => 'keystone_authtoken', param => 'auth_url', value => $controller_train::params::glance_auth_url, }
  controller_train::configure_glance::do_config { 'glance_api_project_domain_name': conf_file => '/etc/glance/glance-api.conf', section => 'keystone_authtoken', param => 'project_domain_name', value => $controller_train::params::project_domain_name, }
  controller_train::configure_glance::do_config { 'glance_api_user_domain_name': conf_file => '/etc/glance/glance-api.conf', section => 'keystone_authtoken', param => 'user_domain_name', value => $controller_train::params::user_domain_name, }
  controller_train::configure_glance::do_config { 'glance_api_project_name': conf_file => '/etc/glance/glance-api.conf', section => 'keystone_authtoken', param => 'project_name', value => $controller_train::params::project_name, }
  controller_train::configure_glance::do_config { 'glance_api_username': conf_file => '/etc/glance/glance-api.conf', section => 'keystone_authtoken', param => 'username', value => $controller_train::params::glance_username, }
  controller_train::configure_glance::do_config { 'glance_api_password': conf_file => '/etc/glance/glance-api.conf', section => 'keystone_authtoken', param => 'password', value => $controller_train::params::glance_password, }
  controller_train::configure_glance::do_config { 'glance_api_cafile': conf_file => '/etc/glance/glance-api.conf', section => 'keystone_authtoken', param => 'cafile', value => $controller_train::params::cafile, }
  controller_train::configure_glance::do_config { 'glance_api_memcached_servers': conf_file => '/etc/glance/glance-api.conf', section => 'keystone_authtoken', param => 'memcached_servers', value => $controller_train::params::memcached_servers, }
  controller_train::configure_glance::do_config { 'glance_api_auth_type': conf_file => '/etc/glance/glance-api.conf', section => 'keystone_authtoken', param => 'auth_type', value => $controller_train::params::auth_type, }

  controller_train::configure_glance::do_config { 'glance_api_flavor': conf_file => '/etc/glance/glance-api.conf', section => 'paste_deploy', param => 'flavor', value => $controller_train::params::flavor, }

#
# stores and default_store deprecated against new attributes enabled_backends and default_backend
# But this causes problems with add location: let's revert to old mode       
#  controller_train::configure_glance::do_config { 'glance_api_store': conf_file => '/etc/glance/glance-api.conf', section => 'glance_store', param => 'stores', value => $controller_train::params::glance_store, }
#  controller_train::configure_glance::do_config { 'glance_api_default_store': conf_file => '/etc/glance/glance-api.conf', section => 'glance_store', param => 'default_store', value => $controller_train::params::glance_api_default_store, }
# In train we try to enable multiple stores back
  controller_train::configure_glance::do_config { 'glance_api_default_store': conf_file => '/etc/glance/glance-api.conf', section => 'glance_store', param => 'default_backend', value => $controller_train::params::glance_api_default_store, }

# File backend       
  controller_train::configure_glance::do_config { 'glance_api_store_datadir': conf_file => '/etc/glance/glance-api.conf', section => 'glance_store', param => 'filesystem_store_datadir', value => $controller_train::params::glance_store_datadir, }

# Ceph backend       
# api_rbd_store_* gets its own section in train [glance_store] ==> [rbd]
# In train we also get a 'description' parameter for each enabled backend
  controller_train::configure_glance::do_config { 'glance_api_rbd_store_description': conf_file => '/etc/glance/glance-api.conf', section => 'rbd', param => 'store_description', value => $controller_train::params::glance_api_rbd_store_description, }
  controller_train::configure_glance::do_config { 'glance_api_rbd_store_pool': conf_file => '/etc/glance/glance-api.conf', section => 'rbd', param => 'rbd_store_pool', value => $controller_train::params::glance_api_rbd_store_pool, }
  controller_train::configure_glance::do_config { 'glance_api_rbd_store_user': conf_file => '/etc/glance/glance-api.conf', section => 'rbd', param => 'rbd_store_user', value => $controller_train::params::glance_api_rbd_store_user, }
  controller_train::configure_glance::do_config { 'glance_api_rbd_store_ceph_conf': conf_file => '/etc/glance/glance-api.conf', section => 'rbd', param => 'rbd_store_ceph_conf', value => $controller_train::params::ceph_rbd_ceph_conf, }
  controller_train::configure_glance::do_config { 'glance_api_rbd_store_chunk_size': conf_file => '/etc/glance/glance-api.conf', section => 'rbd', param => 'rbd_store_chunk_size', value => $controller_train::params::glance_api_rbd_store_chunk_size, }
       
###############
# Settings needed for ceilomer
# Probably useess now (but doesn't cause problems)       
  controller_train::configure_glance::do_config { 'glance_api_transport_url': conf_file => '/etc/glance/glance-api.conf', section => 'DEFAULT', param => 'transport_url', value => $controller_train::params::transport_url, }
   
#######Proxy headers parsing
  controller_train::configure_glance::do_config { 'glance_enable_proxy_headers_parsing': conf_file => '/etc/glance/glance-api.conf', section => 'oslo_middleware', param => 'enable_proxy_headers_parsing', value => $controller_train::params::enable_proxy_headers_parsing, }

     
## PEM da train glance-registry non c'e' piu'
#  glance-registry.conf
#
#  controller_train::configure_glance::do_config { 'glance_reg_db': conf_file => '/etc/glance/glance-registry.conf', section => 'database', param => 'connection', value => $controller_train::params::glance_db, }
#
##  controller_train::configure_glance::do_config { 'glance_reg_image_verbose': conf_file => '/etc/glance/glance-registry.conf', section => 'DEFAULT', param => 'verbose', value => false, }
#  controller_train::configure_glance::do_config { 'glance_reg_image_size_cap': conf_file => '/etc/glance/glance-registry.conf', section => 'DEFAULT', param => 'image_size_cap', value => $controller_train::params::glance_image_size_cap, }
#  # FF in rocky [keystone_authtoken] auth_uri diventa www_authenticate_uri
#  controller_train::configure_glance::do_config { 'glance_reg_www_authenticate_uri': conf_file => '/etc/glance/glance-registry.conf', section => 'keystone_authtoken', param => 'www_authenticate_uri', value => $controller_train::params::www_authenticate_uri, }
#  # FF in queens e rocky [keystone_authtoken] auth_url gira sulla porta 5000
#  controller_train::configure_glance::do_config { 'glance_reg_auth_url': conf_file => '/etc/glance/glance-registry.conf', section => 'keystone_authtoken', param => 'auth_url', value => $controller_train::params::glance_keystone_authtoken_auth_url, }
#  controller_train::configure_glance::do_config { 'glance_reg_project_domain_name': conf_file => '/etc/glance/glance-registry.conf', section => 'keystone_authtoken', param => 'project_domain_name', value => $controller_train::params::project_domain_name, }
#  controller_train::configure_glance::do_config { 'glance_reg_user_domain_name': conf_file => '/etc/glance/glance-registry.conf', section => 'keystone_authtoken', param => 'user_domain_name', value => $controller_train::params::user_domain_name, }
#  controller_train::configure_glance::do_config { 'glance_reg_project_name': conf_file => '/etc/glance/glance-registry.conf', section => 'keystone_authtoken', param => 'project_name', value => $controller_train::params::project_name, }
#  controller_train::configure_glance::do_config { 'glance_reg_username': conf_file => '/etc/glance/glance-registry.conf', section => 'keystone_authtoken', param => 'username', value => $controller_train::params::glance_username, }
#  controller_train::configure_glance::do_config { 'glance_reg_password': conf_file => '/etc/glance/glance-registry.conf', section => 'keystone_authtoken', param => 'password', value => $controller_train::params::glance_password, }
#  controller_train::configure_glance::do_config { 'glance_reg_cafile': conf_file => '/etc/glance/glance-registry.conf', section => 'keystone_authtoken', param => 'cafile', value => $controller_train::params::cafile, }
#  controller_train::configure_glance::do_config { 'glance_reg_memcached_servers': conf_file => '/etc/glance/glance-registry.conf', section => 'keystone_authtoken', param => 'memcached_servers', value => $controller_train::params::memcached_servers, }
#  controller_train::configure_glance::do_config { 'glance_reg_auth_type': conf_file => '/etc/glance/glance-registry.conf', section => 'keystone_authtoken', param => 'auth_type', value => $controller_train::params::auth_type, }
#
#  controller_train::configure_glance::do_config { 'glance_reg_flavor': conf_file => '/etc/glance/glance-registry.conf', section => 'paste_deploy', param => 'flavor', value => $controller_train::params::flavor, }
# 
## Settings needed for ceilomer     
##  controller_train::configure_glance::do_config { 'glance_reg_notification_driver': conf_file => '/etc/glance/glance-registry.conf', section => 'oslo_messaging_notifications', param => 'driver', value => $controller_train::params::glance_notification_driver, }
#  controller_train::configure_glance::do_config { 'glance_reg_transport_url': conf_file => '/etc/glance/glance-registry.conf', section => 'DEFAULT', param => 'transport_url', value => $controller_train::params::transport_url, }
}

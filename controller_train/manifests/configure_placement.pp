class controller_train::configure_placement inherits controller_train::params {

#
# Questa classe:
# - popola il file /etc/placement/placement.conf
# - crea il file /etc/placement/policy.json
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


# placement.conf
   controller_train::configure_placement::do_config { 'placement_db': conf_file => '/etc/placement/placement.conf', section => 'placement_database', param => 'connection', value => $controller_train::params::placement_db, }

   controller_train::configure_placement::do_config { 'placement_auth_strategy': conf_file => '/etc/placement/placement.conf', section => 'api', param => 'auth_strategy', value => $controller_train::params::auth_strategy, }

   controller_train::configure_placement::do_config { 'placement_auth_url': conf_file => '/etc/placement/placement.conf', section => 'keystone_authtoken', param => 'auth_url', value => $controller_train::params::placement_auth_url, }  
   controller_train::configure_placement::do_config { 'placement_memcached_servers': conf_file => '/etc/placement/placement.conf', section => 'keystone_authtoken', param => 'memcached_servers', value => $controller_train::params::memcached_servers, }
   controller_train::configure_placement::do_config { 'placement_auth_plugin': conf_file => '/etc/placement/placement.conf', section => 'keystone_authtoken', param => 'auth_type', value => $controller_train::params::auth_type, }
   controller_train::configure_placement::do_config { 'placement_project_domain_name': conf_file => '/etc/placement/placement.conf', section => 'keystone_authtoken', param => 'project_domain_name', value => $controller_train::params::project_domain_name, }
   controller_train::configure_placement::do_config { 'placement_user_domain_name': conf_file => '/etc/placement/placement.conf', section => 'keystone_authtoken', param => 'user_domain_name', value => $controller_train::params::user_domain_name, }
   controller_train::configure_placement::do_config { 'placement_project_name': conf_file => '/etc/placement/placement.conf', section => 'keystone_authtoken', param => 'project_name', value => $controller_train::params::project_name, }
   controller_train::configure_placement::do_config { 'placement_username': conf_file => '/etc/placement/placement.conf', section => 'keystone_authtoken', param => 'username', value => $controller_train::params::placement_username, }
   controller_train::configure_placement::do_config { 'placement_password': conf_file => '/etc/placement/placement.conf', section => 'keystone_authtoken', param => 'password', value => $controller_train::params::placement_password, }
   controller_train::configure_placement::do_config { 'placement_www_authenticate_uri': conf_file => '/etc/placement/placement.conf', section => 'keystone_authtoken', param => 'www_authenticate_uri', value => $controller_train::params::www_authenticate_uri, }
   controller_train::configure_placement::do_config { 'placement_cafile': conf_file => '/etc/placement/placement.conf', section => 'keystone_authtoken', param => 'cafile', value => $controller_train::params::cafile, }

######placement_policy is copied from /controller_train/files dir       
file {'placement_policy.json':
           source      => 'puppet:///modules/controller_train/placement_policy.json',
           path        => '/etc/placement/policy.json',
           backup      => true,
           owner   => root,
           group   => placement,
           mode    => "0640",

         }
      
## FF       
file {'00-placement-api.conf':
           source      => 'puppet:///modules/controller_train/00-placement-api.conf',
           path        => '/etc/httpd/conf.d/00-placement-api.conf',
           ensure      => present,
           backup      => true,
           mode        => "0640",
         }
##

}

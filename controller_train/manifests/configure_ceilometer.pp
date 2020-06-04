class controller_ussuri::configure_ceilometer inherits controller_ussuri::params {

#
# Questa classe:
# - popola il file /etc/ceilometer/ceilometer.conf
#
 
##########ceilometer package

 $ceilometerpackages = [ "openstack-ceilometer-collector",
                         "openstack-ceilometer-notification",
                         "openstack-ceilometer-central", 
                         "python2-gnocchiclient",
                         "python2-ceilometerclient" ]

 package { $ceilometerpackages: ensure => "installed" }

########

 
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
  $split = split($name, ':')
  $value = $split[-1]
  $index = $split[-2]

  augeas { "augeas/${conf_file}/${section}/${param}/${index}/${name}":
    lens    => "PythonPaste.lns",
    incl    => $conf_file,
    changes => [ "set ${section}/${param}[${index}] ${value}" ],
    onlyif  => "get ${section}/${param}[${index}] != ${value}"
  }
}

define do_config_list (
  $conf_file = '/etc/ceilometer/ceilometer.conf',
  $section = 'DEFAULT',
  $param,
  $values
) {

  $values_size = size($values)

  # remove the entire block if the size doesn't match
  augeas { "remove_${conf_file}_${section}_${param}":
    lens    => "PythonPaste.lns",
    incl    => $conf_file,
    changes => [ "rm ${section}/${param}" ],
    onlyif  => "match ${section}/${param} size > ${values_size}"
  }

  $namevars = array_to_namevars($values, "${conf_file}:${section}:${param}")

  # check each value
  do_augeas_config { $namevars:
    conf_file => $conf_file,
    section => $section,
    param => $param
  }
}


                                                                                                                                  
# ceilometer.conf
   do_config { 'ceilometer_connection': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'database', param => 'connection', value => $controller_ussuri::params::ceilometer_connection, }
   ####ok
   do_config { 'ceilometer_metering_time_to_live': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'database', param => 'metering_time_to_live', value => $controller_ussuri::params::ceilometer_metering_time_to_live, }
       
###########
#   do_config { 'ceilometer_rpc_backend': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'DEFAULT', param => 'rpc_backend', value => $controller_ussuri::params::rpc_backend, }
###transport_url
do_config { 'ceilometer_transport_url': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'DEFAULT', param => 'transport_url', value => $controller_ussuri::params::transport_url, }
#############
   do_config { 'ceilometer_auth_strategy': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'DEFAULT', param => 'auth_strategy', value => $controller_ussuri::params::auth_strategy, }
# See https://issues.infn.it/jira/browse/PDCL-749
   do_config { 'ceilometer_default_log_levels': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'DEFAULT', param => 'default_log_levels', value => $controller_ussuri::params::ceilometer_default_log_levels, }

   do_config { 'ceilometer_auth_uri': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'keystone_authtoken', param => 'auth_uri', value => $controller_ussuri::params::auth_uri, }
   do_config { 'ceilometer_auth_url': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'keystone_authtoken', param => 'auth_url', value => $controller_ussuri::params::auth_url, }
   do_config { 'ceilometer_memcached_servers': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'keystone_authtoken', param => 'memcached_servers', value => $controller_ussuri::params::memcached_servers, }
   do_config { 'ceilometer_project_name': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'keystone_authtoken', param => 'project_name', value => $controller_ussuri::params::project_name, }
   do_config { 'ceilometer_username': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'keystone_authtoken', param => 'username', value => $controller_ussuri::params::ceilometer_username, }
   do_config { 'ceilometer_password': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'keystone_authtoken', param => 'password', value => $controller_ussuri::params::ceilometer_password, }
   do_config { 'ceilometer_cafile': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'keystone_authtoken', param => 'cafile', value => $controller_ussuri::params::cafile, }
   do_config { 'ceilometer_auth_type': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'keystone_authtoken', param => 'auth_type', value => $controller_ussuri::params::auth_type, }
   do_config { 'ceilometer_project_domain_name': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'keystone_authtoken', param => 'project_domain_name', value => $controller_ussuri::params::project_domain_name, }
   do_config { 'ceilometer_user_domain_name': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'keystone_authtoken', param => 'user_domain_name', value => $controller_ussuri::params::user_domain_name, }

   do_config { 'ceilometer_service_credentials_auth_type': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'service_credentials', param => 'auth_type', value => $controller_ussuri::params::auth_type, }
   do_config { 'ceilometer_service_credentials_auth_url': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'service_credentials', param => 'auth_url', value => $controller_ussuri::params::ceilometer_service_credentials_auth_url, }
   do_config { 'ceilometer_service_credentials_project_domain_name': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'service_credentials', param => 'project_domain_name', value => $controller_ussuri::params::project_domain_name, }
   do_config { 'ceilometer_service_credentials_user_domain_name': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'service_credentials', param => 'user_domain_name', value => $controller_ussuri::params::user_domain_name, }
   do_config { 'ceilometer_service_credentials_project_name': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'service_credentials', param => 'project_name', value => $controller_ussuri::params::project_name, }
   do_config { 'ceilometer_service_credentials_username': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'service_credentials', param => 'username', value => $controller_ussuri::params::ceilometer_username, }
   do_config { 'ceilometer_service_credentials_password': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'service_credentials', param => 'password', value => $controller_ussuri::params::ceilometer_password, }
   do_config { 'ceilometer_service_credentials_interface': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'service_credentials', param => 'interface', value => $controller_ussuri::params::ceilometer_service_credentials_interface, }
   do_config { 'ceilometer_service_credentials_region_name': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'service_credentials', param => 'region_name', value => $controller_ussuri::params::region_name, }
   do_config { 'ceilometer_service_credentials_cafile': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'service_credentials', param => 'cafile', value => $controller_ussuri::params::cafile,
 }
  

  do_config_list { 'ceilometer_meter_dispatchers':
    conf_file => '/etc/ceilometer/ceilometer.conf',
    section   => 'DEFAULT',
    param     => 'meter_dispatchers',
    values    => $controller_ussuri::params::ceilometer_meter_dispatchers,
  }

  do_config_list { 'ceilometer_event_dispatchers':
    conf_file => '/etc/ceilometer/ceilometer.conf',
    section   => 'DEFAULT',
    param     => 'event_dispatchers',
    values    => $controller_ussuri::params::ceilometer_event_dispatchers,
  }

  do_config { 'ceilometer__dispatcher_gnocchi__filter_service_activity':
    conf_file => '/etc/ceilometer/ceilometer.conf',
    section => 'dispatcher_gnocchi',
    param => 'filter_service_activity',
    value => $controller_ussuri::params::ceilometer__dispatcher_gnocchi__filter_service_activity,
  }

  do_config { 'ceilometer__dispatcher_gnocchi__archive_policy':
    conf_file => '/etc/ceilometer/ceilometer.conf',
    section => 'dispatcher_gnocchi',
    param => 'archive_policy',
    value => $controller_ussuri::params::ceilometer__dispatcher_gnocchi__archive_policy,
  }

#######Proxy headers parsing
do_config { 'ceilometer_enable_proxy_headers_parsing': conf_file => '/etc/ceilometer/ceilometer.conf', section => 'oslo_middleware', param => 'enable_proxy_headers_parsing', value => $controller_ussuri::params::enable_proxy_headers_parsing, }

  }

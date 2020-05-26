class controller_ussuri ($cloud_role_foreman = "undefined") {

  $cloud_role = $cloud_role_foreman

  $ocatapackages = [ "openstack-utils",

                   ]


     package { $ocatapackages: ensure => "installed" }

  # Install CA
  class {'controller_ussuri::install_ca_cert':}

  # Ceph
  class {'controller_ussuri::ceph':}
  
  # Configure keystone
  class {'controller_ussuri::configure_keystone':}
  
  # Configure glance
  class {'controller_ussuri::configure_glance':}

  # Configure nova
  class {'controller_ussuri::configure_nova':}

  # Configure ec2
  class {'controller_ussuri::configure_ec2':}

  # Configure neutron
  class {'controller_ussuri::configure_neutron':}

  # Configure cinder
  class {'controller_ussuri::configure_cinder':}

  # Configure heat
  class {'controller_ussuri::configure_heat':}

#  # Configure ceilometer
#  class {'controller_ussuri::configure_ceilometer':}

  # Configure horizon
  class {'controller_ussuri::configure_horizon':}

  # Configure Shibboleth if AII and Shibboleth are enabled
  if ($::controller_ussuri::params::enable_aai_ext and $::controller_ussuri::params::enable_shib)  {
    class {'controller_ussuri::configure_shibboleth':}
  }

  # Configure OpenIdc if AII and openidc are enabled
  if ($::controller_ussuri::params::enable_aai_ext and $::controller_ussuri::params::enable_oidc)  {
    class {'controller_ussuri::configure_openidc':}
  }
 
  # Service
  class {'controller_ussuri::service':}

  
  # do passwdless access
  class {'controller_ussuri::pwl_access':}
  
  
  # configure remote syslog
  class {'controller_ussuri::rsyslog':}
  
  

       Class['controller_ussuri::install_ca_cert'] -> Class['controller_ussuri::configure_keystone']
       Class['controller_ussuri::configure_keystone'] -> Class['controller_ussuri::configure_glance']
       Class['controller_ussuri::configure_glance'] -> Class['controller_ussuri::configure_nova']
       Class['controller_ussuri::configure_nova'] -> Class['controller_ussuri::configure_neutron']
       Class['controller_ussuri::configure_neutron'] -> Class['controller_ussuri::configure_cinder']
       Class['controller_ussuri::configure_cinder'] -> Class['controller_ussuri::configure_horizon']
       Class['controller_ussuri::configure_horizon'] -> Class['controller_ussuri::configure_heat']
       #Class['controller_ussuri::configure_heat'] -> Class['controller_ussuri::configure_ceilometer']
       #if ($enable_aai_ext and $enable_shib)  {
       #   Class['controller_ussuri::configure_ceilometer'] -> Class['controller_ussuri::configure_shibboleth']
       #}
       #if ($enable_aai_ext and $enable_oidc) {
       #   Class['controller_ussuri::configure_ceilometer'] -> Class['controller_ussuri::configure_openidc']
       #}
       #Class['controller_ussuri::configure_ceilometer'] -> Class['controller_ussuri::service']
            

  }

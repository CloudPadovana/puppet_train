class controller_train ($cloud_role_foreman = "undefined") {

  $cloud_role = $cloud_role_foreman

  $ocatapackages = [ "crudini",

                   ]


     package { $ocatapackages: ensure => "installed" }

  # Install CA
  class {'controller_train::install_ca_cert':}

  # Ceph
  class {'controller_train::ceph':}
  
  # Configure keystone
  class {'controller_train::configure_keystone':}
  
  # Configure glance
  class {'controller_train::configure_glance':}

  # Configure nova
  class {'controller_train::configure_nova':}

## FF for placement in train
  # Configure placement
  class {'controller_train::configure_placement':}
###

  # Configure ec2
  class {'controller_train::configure_ec2':}

  # Configure neutron
  class {'controller_train::configure_neutron':}

  # Configure cinder
  class {'controller_train::configure_cinder':}

  # Configure heat
  class {'controller_train::configure_heat':}

  # Configure horizon
  class {'controller_train::configure_horizon':}

  # Configure Shibboleth if AII and Shibboleth are enabled
  if ($::controller_train::params::enable_aai_ext and $::controller_train::params::enable_shib)  {
    class {'controller_train::configure_shibboleth':}
  }

  # Configure OpenIdc if AII and openidc are enabled
  if ($::controller_train::params::enable_aai_ext and ($::controller_train::params::enable_oidc or $::controller_train::params::enable_infncloud))  {
    class {'controller_train::configure_openidc':}
  }
 
  # Service
  class {'controller_train::service':}

  
  # do passwdless access
  class {'controller_train::pwl_access':}
  
  
  # configure remote syslog
  class {'controller_train::rsyslog':}
  
  

       Class['controller_train::install_ca_cert'] -> Class['controller_train::configure_keystone']
       Class['controller_train::configure_keystone'] -> Class['controller_train::configure_glance']
       Class['controller_train::configure_glance'] -> Class['controller_train::configure_nova']
       Class['controller_train::configure_nova'] -> Class['controller_train::configure_placement']
       Class['controller_train::configure_placement'] -> Class['controller_train::configure_neutron']
       Class['controller_train::configure_neutron'] -> Class['controller_train::configure_cinder']
       Class['controller_train::configure_cinder'] -> Class['controller_train::configure_horizon']
       Class['controller_train::configure_horizon'] -> Class['controller_train::configure_heat']

  }

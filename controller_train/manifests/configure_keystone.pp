class controller_train::configure_keystone inherits controller_train::params {

#
# Questa classe:
# - popola il file /etc/keystone/keystone.conf
# - crea il file /etc/httpd/conf.d/wsgi-keystone.conf
#
  
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
  controller_train::configure_keystone::do_augeas_config { $namevars:
    conf_file => $conf_file,
    section => $section,
    param => $param
  }
}

# keystone.conf
## Not needed anymore (needed only for the very first installation)
##  controller_train::configure_keystone::do_config { 'keystone_admin_token': conf_file => '/etc/keystone/keystone.conf', section => 'DEFAULT', param => 'admin_token', value => $controller_train::params::admin_token, }


  controller_train::configure_keystone::do_config { 'keystone_public_endpoint': conf_file => '/etc/keystone/keystone.conf', section => 'DEFAULT', param => 'public_endpoint', value => $controller_train::params::keystone_public_endpoint, }

# Deprecated
# Reason: With the removal of the 2.0 API keystone does not distinguish between
# admin and public endpoints.
#controller_train::configure_keystone::do_config { 'keystone_admin_endpoint': conf_file => '/etc/keystone/keystone.conf', section => 'DEFAULT', param => 'admin_endpoint', value #=> $controller_train::params::keystone_admin_endpoint, }

  controller_train::configure_keystone::do_config { 'keystone_db': conf_file => '/etc/keystone/keystone.conf', section => 'database', param => 'connection', value => $controller_train::params::keystone_db, }

  controller_train::configure_keystone::do_config { 'keystone_token_provider': conf_file => '/etc/keystone/keystone.conf', section => 'token', param => 'provider', value => $controller_train::params::keystone_token_provider, }
  controller_train::configure_keystone::do_config { 'keystone_token_expiration': conf_file => '/etc/keystone/keystone.conf', section => 'token', param => 'expiration', value => $controller_train::params::token_expiration, }



       
#######Proxy headers parsing
  controller_train::configure_keystone::do_config { 'keystone_enable_proxy_headers_parsing': conf_file => '/etc/keystone/keystone.conf', section => 'oslo_middleware', param => 'enable_proxy_headers_parsing', value => $controller_train::params::enable_proxy_headers_parsing, }


##  controller_train::configure_keystone::do_config { 'keystone_auth_methods': conf_file => '/etc/keystone/keystone.conf', section => 'auth', param => 'methods', value => $controller_train::params::keystone_auth_methods, }



   file { "/usr/share/keystone/wsgi-keystone.conf":
     ensure   => file,
     owner    => "root",
     group    => "root",
     mode     => '0644',
     content  => template("controller_train/wsgi-keystone.conf.erb"),
   }

   file { '/etc/httpd/conf.d/wsgi-keystone.conf':
     ensure => link,
     target => '/usr/share/keystone/wsgi-keystone.conf',
   }

  
  ############################################################################
  #  OS-Federation setup
  ############################################################################

  if $enable_aai_ext {

    controller_train::configure_keystone::do_config { 'keystone_auth_methods':
      conf_file => '/etc/keystone/keystone.conf',
      section   => 'auth',
      param     => 'methods',
      value     => 'password,token,mapped,openid',
    }

    controller_train::configure_keystone::do_config_list { "keystone_trusted_dashboards":
      conf_file => '/etc/keystone/keystone.conf',
      section   => 'federation',
      param     => 'trusted_dashboard',
      values    => [ "https://${site_fqdn}/dashboard/auth/websso/", "https://${cv_site_fqdn}/dashboard/auth/websso/" ],
    }
    
    controller_train::configure_keystone::do_config { "keystone_shib_attr":
      conf_file => '/etc/keystone/keystone.conf',
      section   => 'mapped',
      param     => 'remote_id_attribute',
      value     => 'Shib-Identity-Provider',
    }

    if $enable_oidc {
      controller_train::configure_keystone::do_config { "keystone_oidc_attr":
        conf_file => '/etc/keystone/keystone.conf',
        section   => 'openid',
        param     => 'remote_id_attribute',
        value     => 'HTTP_OIDC_ISS',
      }
    }

    if $enable_infncloud {
      controller_train::configure_keystone::do_config { "keystone_oidc_attr":
        conf_file => '/etc/keystone/keystone.conf',
        section   => 'openid',
        param     => 'remote_id_attribute',
        value     => 'OIDC_CLAIM_iss',
      }
    }

    file { "/etc/keystone/policy.json":
      ensure   => file,
      owner    => "keystone",
      group    => "keystone",
      mode     => '0640',
      source  => "puppet:///modules/controller_train/policy.json",
    }

    ### Patch for error handling in OS-Federation
    package { "patch":
      ensure  => installed,
    }

    file { "/usr/share/keystone/application.patch":
      ensure   => file,
      owner    => "keystone",
      group    => "keystone",
      mode     => '0640',
      source  => "puppet:///modules/controller_train/application.patch",
    }
    
    exec { "patch-controllers":
      command => "/usr/bin/patch /usr/lib/python2.7/site-packages/keystone/server/flask/application.py /usr/share/keystone/application.patch",
      unless  => "/bin/grep Keystone-patch-0002 /usr/lib/python2.7/site-packages/keystone/server/flask/application.py 2>/dev/null >/dev/null",
      require => [ File["/usr/share/keystone/application.patch"], Package["patch"] ],
    }

  }
     
}

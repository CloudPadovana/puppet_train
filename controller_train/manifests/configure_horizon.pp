class controller_train::configure_horizon inherits controller_train::params {
  
  file { "/etc/httpd/conf.d/ssl.conf":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    content  => template("controller_train/ssl.conf.erb"),
  }
  
  file { "/etc/httpd/conf.d/openstack-dashboard.conf":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    content  => file("controller_train/openstack-dashboard.conf"),
  }
 
  file { "/etc/openstack-dashboard/local_settings":
    ensure   => file,
    owner    => "root",
    group    => "apache",
    mode     => "0640",
    content  => template("controller_train/local_settings.erb"),
  }

  file { '/var/log/horizon/horizon_log':
    path    => '/var/log/horizon/horizon.log',
    ensure  => 'present',
    owner   => 'apache',
    group   => 'apache',
    mode     => "0644",
  }

#  exec { "port_80_closed":
#    command => "/usr/bin/sed -i -e 's|^Listen\\s*80\\s*|#Listen 80|g' /etc/httpd/conf/httpd.conf" ,
#    unless  => "/bin/grep '#Listen\\s*80\\s*$' /etc/httpd/conf/httpd.conf",
#  }


  ############################################################################
  #  OS-Federation
  ############################################################################
  if $enable_aai_ext {
 
    exec { "download_cap_repo":
      command => "/usr/bin/wget -q -O /etc/yum.repos.d/openstack-security-integrations.repo ${cap_repo_url}",
      unless  => "/bin/grep Rocky /etc/yum.repos.d/openstack-security-integrations.repo 2>/dev/null >/dev/null",
    }

    package { ["openstack-auth-cap", "openstack-auth-shib"]:
      ensure  => latest,
      require => Exec["download_cap_repo"],
    }
  
    file { "/usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1002_aai_settings.py":
      ensure   => file,
      owner    => "root",
      group    => "apache",
      mode     => "0640",
      content  => template("controller_train/aai_settings.py.erb"),
    }

    file { "/usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1003_infnaai_settings.py":
      ensure   => file,
      owner    => "root",
      group    => "apache",
      mode     => "0640",
      content  => template("controller_train/infnaai_settings.py.erb"),
    }

    file { "/usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1003_unipdsso_settings.py":
      ensure   => file,
      owner    => "root",
      group    => "apache",
      mode     => "0640",
      content  => template("controller_train/unipdsso_settings.py.erb"),
    }

    file { "/usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1003_oidc_settings.py":
      ensure   => file,
      owner    => "root",
      group    => "apache",
      mode     => "0640",
      content  => template("controller_train/oidc_settings.py.erb"),
    }

    file { "/etc/openstack-auth-shib/notifications/notifications_en.txt":
      ensure   => file,
      owner    => "root",
      group    => "root",
      mode     => "0644",
      content  => template("controller_train/notifications_en.txt.erb"),
      require  => Package["openstack-auth-cap"],
    }


  ### DB Creation if not exist and grant privileges.

    package { "mariadb":
      ensure  => installed,
    }

    exec { "create-$aai_db_name-db":
        command => "/usr/bin/mysql -u root -p${mysql_admin_password} -h ${aai_db_host} -e \"create database IF NOT EXISTS ${aai_db_name}; grant all on ${aai_db_name}.* to ${aai_db_user}@localhost identified by '${aai_db_pwd}'; grant all on ${aai_db_name}.* to ${aai_db_user}@'${vip_mgmt}' identified by '${aai_db_pwd}'; grant all on ${aai_db_name}.* to ${aai_db_user}@'${ip_ctrl1}' identified by '${aai_db_pwd}'; grant all on ${aai_db_name}.* to ${aai_db_user}@'${ip_ctrl2}' identified by '${aai_db_pwd}';\"",
        unless  => "/usr/bin/mysql -u root -p${mysql_admin_password} -h ${aai_db_host} -e \"show DATABASES LIKE '${aai_db_name}';\"",
        require => Package["mariadb"],
    }

    exec { "makemigrations_db":
        command => "/usr/bin/python /usr/share/openstack-dashboard/manage.py makemigrations --name ocata_changes openstack_auth_shib && /usr/sbin/runuser -s /bin/bash -c 'python /usr/share/openstack-dashboard/manage.py migrate' -- apache || echo ignoreerrors",
        onlyif  => "/usr/bin/test ! -e /usr/lib/python2.7/site-packages/openstack_auth_shib/migrations/*_ocata_changes.py",
        require => Exec["create-$aai_db_name-db"],
    }

  ### Patch for AAI testing IdP

    if $::controller_train::cloud_role == "is_test" {

      exec { "patch_infnaai_testing_idp":
        command => "/bin/sed -i 's|idp.infn.it/saml2|idp.infn.it/testing/saml2|g' /usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1001_cap_settings.py",
        unless  => "/bin/grep idp.infn.it/testing/saml2 /usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1001_cap_settings.py 2>/dev/null >/dev/null",
        require => Package["openstack-auth-cap"],
      }

      exec { "patch_unipdaai_testing_idp":
        command => "/bin/sed -i 's|shibidp.cca.unipd.it|shibidpdev.cca.unipd.it|g' /usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1001_cap_settings.py",
        unless  => "/bin/grep shibidpdev.cca.unipd.it /usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1001_cap_settings.py 2>/dev/null >/dev/null",
        require => Package["openstack-auth-cap"],
      }

    }

  }

  ############################################################################
  #  Cron-scripts configuration
  ############################################################################

  file { "/etc/openstack-auth-shib/actions.conf":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0600",
    content  => template("controller_train/actions.conf.erb"),
  }
  
  if "${::fqdn}" =~ /01/ {
    $renew_schedule = "15 0 * * *"
  } else {
    $renew_schedule = "30 0 * * *"
  }
  
  file { "/etc/cron.d/openstack-auth-shib-cron":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => '0644',
    content  => template("controller_train/openstack-auth-shib-cron.erb"),
  }

}

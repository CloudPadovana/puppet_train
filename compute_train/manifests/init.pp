class compute_train ($cloud_role_foreman = "undefined") { 

  $cloud_role = $cloud_role_foreman  

  # system check setting (network, selinux, CA files)
    class {'compute_train::systemsetting':}

  # stop services 
    class {'compute_train::stopservices':}

  # install
    class {'compute_train::install':}

  # setup firewall
    class {'compute_train::firewall':}

  # setup bacula
    class {'compute_train::bacula':}
  
  # setup libvirt
    class {'compute_train::libvirt':}

  # setup ceph
    class {'compute_train::ceph':}

  # setup rsyslog
    class {'compute_train::rsyslog':}

  # service
    class {'compute_train::service':}

  # install and configure nova
     class {'compute_train::nova':}

  # install and configure neutron
     class {'compute_train::neutron':}

  # nagios settings
     class {'compute_train::nagiossetting':}

  # do passwdless access
      class {'compute_train::pwl_access':}

    # configure collectd
      class {'compute_train::collectd':}


# execution order
             Class['compute_train::firewall'] -> Class['compute_train::systemsetting']
             Class['compute_train::systemsetting'] -> Class['compute_train::stopservices']
             Class['compute_train::stopservices'] -> Class['compute_train::install']
             Class['compute_train::install'] -> Class['compute_train::bacula']
             Class['compute_train::bacula'] -> Class['compute_train::nova']
             Class['compute_train::nova'] -> Class['compute_train::libvirt']
             Class['compute_train::libvirt'] -> Class['compute_train::neutron']
             Class['compute_train::neutron'] -> Class['compute_train::ceph']
             Class['compute_train::ceph'] -> Class['compute_train::nagiossetting']
             Class['compute_train::nagiossetting'] -> Class['compute_train::pwl_access']
             Class['compute_train::pwl_access'] -> Class['compute_train::collectd']
             Class['compute_train::collectd'] -> Class['compute_train::service']
################           
}
  

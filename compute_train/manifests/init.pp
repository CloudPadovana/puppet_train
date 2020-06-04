class compute_ussuri ($cloud_role_foreman = "undefined") { 

  $cloud_role = $cloud_role_foreman  

  # system check setting (network, selinux, CA files)
    class {'compute_ussuri::systemsetting':}

  # stop services 
    class {'compute_ussuri::stopservices':}

  # install
    class {'compute_ussuri::install':}

  # setup firewall
    class {'compute_ussuri::firewall':}

  # setup bacula
    class {'compute_ussuri::bacula':}
  
  # setup libvirt
    class {'compute_ussuri::libvirt':}

  # setup ceph
    class {'compute_ussuri::ceph':}

  # setup rsyslog
    class {'compute_ussuri::rsyslog':}

  # service
    class {'compute_ussuri::service':}

  # install and configure nova
     class {'compute_ussuri::nova':}

  # install and configure neutron
     class {'compute_ussuri::neutron':}

  # nagios settings
     class {'compute_ussuri::nagiossetting':}

  # do passwdless access
      class {'compute_ussuri::pwl_access':}

    # configure collectd
      class {'compute_ussuri::collectd':}


# execution order
             Class['compute_ussuri::firewall'] -> Class['compute_ussuri::systemsetting']
             Class['compute_ussuri::systemsetting'] -> Class['compute_ussuri::stopservices']
             Class['compute_ussuri::stopservices'] -> Class['compute_ussuri::install']
             Class['compute_ussuri::install'] -> Class['compute_ussuri::bacula']
             Class['compute_ussuri::bacula'] -> Class['compute_ussuri::nova']
             Class['compute_ussuri::nova'] -> Class['compute_ussuri::libvirt']
             Class['compute_ussuri::libvirt'] -> Class['compute_ussuri::neutron']
             Class['compute_ussuri::neutron'] -> Class['compute_ussuri::ceph']
             Class['compute_ussuri::ceph'] -> Class['compute_ussuri::nagiossetting']
             Class['compute_ussuri::nagiossetting'] -> Class['compute_ussuri::pwl_access']
             Class['compute_ussuri::pwl_access'] -> Class['compute_ussuri::collectd']
             Class['compute_ussuri::collectd'] -> Class['compute_ussuri::service']
################           
}
  

class controller_train::configure_shibboleth inherits controller_train::params {

  exec { "download_shib_repo":
    command => "/usr/bin/wget -q -O /etc/yum.repos.d/shibboleth.repo ${shib_repo_url}",
    creates => "/etc/yum.repos.d/shibboleth.repo",
  }
  
  package { "shibboleth":
    ensure  => present,
    require => Exec["download_shib_repo"],
  }
  
  file { "/etc/shibboleth/horizon-infn-key.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0400",
    source   => "${host_key}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/horizon-infn-cert.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0600",
    source   => "${host_cert}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/horizon-unipd-key.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0400",
    source   => "${unipd_key}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/horizon-unipd-cert.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0600",
    source   => "${unipd_cert}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/keystone-infn-key.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0400",
    source   => "${keystone_infn_key}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/keystone-infn-cert.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0600",
    source   => "${keystone_infn_cert}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/keystone-unipd-key.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0400",
    source   => "${keystone_unipd_key}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/keystone-unipd-cert.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0600",
    source   => "${keystone_unipd_cert}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/attribute-map.xml":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    source   => "puppet:///modules/controller_train/attribute-map.xml",
    tag      => ["shibboleth_conf"],
  }

  controller_train::configure_shibboleth::srvmetadata { "/etc/shibboleth/horizon-infn-metadata.xml":
    entityid => "https://${site_fqdn}/dashboard-shib",
    info_url => "${shib_info_url}",
    sp_name  => "Cloud Area Padovana (Horizon)",
    sp_org   => "INFN"
  }

  controller_train::configure_shibboleth::srvmetadata { "/etc/shibboleth/keystone-infn-metadata.xml":
    entityid => "https://${keystone_cap_fqdn}/v3",
    info_url => "${shib_info_url}",
    sp_name  => "Cloud Area Padovana (Keystone)",
    sp_org   => "INFN"
  }


  controller_train::configure_shibboleth::srvmetadata { "/etc/shibboleth/horizon-unipd-metadata.xml":
    entityid => "https://${cv_site_fqdn}/dashboard-shib",
    info_url => "${shib_info_url}",
    sp_name  => "Cloud Veneto (Horizon)",
    sp_org   => "Università degli Studi di Padova"
  }


  controller_train::configure_shibboleth::srvmetadata { "/etc/shibboleth/keystone-unipd-metadata.xml":
    entityid => "https://${keystone_cv_fqdn}/v3",
    info_url => "${shib_info_url}",
    sp_name  => "Cloud Veneto (Keystone)",
    sp_org   => "Università degli Studi di Padova"
  }

  file { "/etc/shibboleth/shibboleth2.xml":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    content  => template("controller_train/shibboleth2.xml.erb"),
    tag      => ["shibboleth_conf"],
  }

  service { "shibd":
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }
  
  Package["shibboleth"] -> File <| tag == 'shibboleth_sec' |> ~> Service["shibd"]
  Package["shibboleth"] -> File <| tag == 'shibboleth_conf' |> ~> Service["shibd"]

  #
  # TODO remove the defined resource when using puppet 4 (resort to epp)
  #
  define srvmetadata ($entityid, $info_url, $sp_name, $sp_org) {
    file { "$title":
      ensure   => file,
      owner    => "root",
      group    => "root",
      mode     => "0644",
      content  => template("controller_train/idem-template-metadata.xml.erb"),
      tag      => ["shibboleth_conf"],
    }
  }

}

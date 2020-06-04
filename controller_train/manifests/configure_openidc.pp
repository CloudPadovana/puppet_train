class controller_train::configure_openidc inherits controller_train::params {

  package { "mod_auth_openidc":
    ensure  => present,
  }
  
  file { "/etc/httpd/conf.d/auth_openidc.conf":
    ensure   => file,
    owner    => "apache",
    group    => "apache",
    mode     => "0640",
    content  => template("controller_train/openidc.conf.erb"),
    tag      => ["oidc_conf"],
  }

  $oidc_providers.each | $prov_id, $prov_data | {
    $oidc_md_url = $prov_data["metadata"]
    $oidc_idp = encode_iss($prov_data["iss"])["dir"]

    $prov_data["clients"].each | $cid, $cdata | {
      $oidc_cache_dir = "${oidc_md_dir}/${cid}"
      $oidc_clientid = $cdata["client_id"]
      $oidc_secret = $cdata["secret"]

      file { "${oidc_cache_dir}":
        ensure  => directory,
        owner   => "apache",
        group   => "apache",
        mode    => "0770",
      }

      exec { "get_${oidc_cache_dir}/${oidc_idp}.provider":
        command => "/usr/bin/wget -q -O ${oidc_cache_dir}/${oidc_idp}.provider ${oidc_md_url}",
        creates => "${oidc_cache_dir}/${oidc_idp}.provider",
        require => File["${oidc_cache_dir}"],
        tag     => ["oidc_conf"],
      }

      file { "${oidc_cache_dir}/${oidc_idp}.client":
        ensure   => file,
        owner    => "apache",
        group    => "apache",
        mode     => "0640",
        content  => "{\"client_id\" : \"${oidc_clientid}\", \"client_secret\" : \"${oidc_secret}\"}\n",
        require  => File["${oidc_cache_dir}"],
        tag      => ["oidc_conf"],
      }

      file { "${oidc_cache_dir}/${oidc_idp}.conf":
        ensure   => file,
        owner    => "apache",
        group    => "apache",
        mode     => "0640",
        content  => "{\"scope\" : \"openid profile email\", \"token_endpoint_auth\" : \"client_secret_basic\", \"response_type\" : \"code\"}\n",
        require  => File["${oidc_cache_dir}"],
        tag      => ["oidc_conf"],
      }
    }
  }

  Package["mod_auth_openidc"] -> File <| tag == 'oidc_conf' |>

}

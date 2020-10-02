class compute_train::libvirt {

include compute_train::params

   $libvirtpackages = [ "libvirt" ]
  
     package { $libvirtpackages: ensure => "installed" }


if $operatingsystemrelease =~ /^8.*/ {

    exec { "Disable socket activation mode for libvirt":
         path => "/usr/bin",
         command => "systemctl mask libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket libvirtd-tcp.socket libvirtd-tls.socket",
         onlyif => "systemctl | grep 'libvirtd.*socket' | grep -v 'masked'",
         require => Package["libvirt"],
         notify => Service['libvirtd'],
  }

}  
#
# systemctl mask libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket libvirtd-tcp.socket libvirtd-tls.socket
# unless systemctl | grep 'libvirtd.*socket.*masked'
    
     service { 'libvirtd':
        ensure => running,
        enable => true,
        hasstatus => true,
        hasrestart => true,
        require => Package["libvirt"],
      }

      file_line { '/etc/libvirt/libvirtd.conf listen_tls':
        path   => '/etc/libvirt/libvirtd.conf',
        line   => 'listen_tls = 0',
        match  => 'listen_tls =',
        notify => Service['libvirtd'],
      }

      file_line { '/etc/libvirt/libvirtd.conf listen_tcp':
        path   => '/etc/libvirt/libvirtd.conf',
        line   => 'listen_tcp = 1',
        match  => 'listen_tcp =',
        notify => Service['libvirtd'],
      }

      file_line { '/etc/libvirt/libvirtd.conf auth_tcp':
        path   => '/etc/libvirt/libvirtd.conf',
        line   => 'auth_tcp = "none"',
        match  => 'auth_tcp =',
        notify => Service['libvirtd'],
      }


     $args_val = '--listen'

     augeas {"/etc/sysconfig/libvirtd libvirtd args":
       context => "/files/etc/sysconfig/libvirtd",
       changes => "set LIBVIRTD_ARGS '\"${args_val}\"'",
       onlyif  => "get LIBVIRTD_ARGS != '\"${args_val}\"'",
            }


      file_line { '/etc/libvirt/qemu.conf user':
        path  => '/etc/libvirt/qemu.conf',
        line  => 'user = "nova"',
        match => '^user =',
      }

      file_line { '/etc/libvirt/qemu.conf group':
        path  => '/etc/libvirt/qemu.conf',
        line  => 'group = "nova"',
        match => '^group =',
      }

      file_line { '/etc/libvirt/qemu.conf dynamic_ownership':
        path  => '/etc/libvirt/qemu.conf',
        line  => 'dynamic_ownership = 0',
        match => 'dynamic_ownership = ',
      }

      Package['libvirt'] -> File_line<| path == '/etc/libvirt/libvirtd.conf' |>
      Package['libvirt'] -> File_line<| path == '/etc/sysconfig/libvirtd' |>
      Package['libvirt'] -> File_line<| path == '/etc/libvirt/qemu.conf' |>

}

class compute_train::pwl_access {

include compute_train::params

  $home_dir = "/var/lib/nova"
  $config = "Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
  "

  user {'nova':
        ensure	=> present,
        shell	=> '/bin/bash',
        require	=> Package["openstack-nova-common"],
       }

# Needed to attach equallogic volumes
    exec {"nova disk membership":
                  unless => "/bin/grep 'disk.*nova' /etc/group 2>/dev/null",
                  command => "/sbin/usermod -a -G disk nova",
                  require => User['nova'],
         }
         
       
  file {"nova_sshdir":
            ensure  => "directory",
            path    => "$home_dir/.ssh",
            owner   => nova,
            group   => nova,
            mode    => "0700",
       }

  File["nova_sshdir"] -> file {
	"config_ssh":
            path    => "$home_dir/.ssh/config",
	    content => "$config",
            owner   => nova,
            group   => nova;

	"private_key":
	    source  => "puppet:///modules/compute_train/$compute_train::params::private_key",
	    path    => "$home_dir/.ssh/id_rsa",
            owner   => nova,
            group   => nova,
            mode    => "0600";

	"public_key":
            path    => "$home_dir/.ssh/id_rsa.pub",
            content => "$compute_train::params::pub_key",
            owner   => nova,
            group   => nova;

        "authorized_keys":
            path    => "$home_dir/.ssh/authorized_keys",
            content => "$compute_train::params::pub_key",
            ensure  => present,
            owner   => nova,
            group   => nova;
       }
}

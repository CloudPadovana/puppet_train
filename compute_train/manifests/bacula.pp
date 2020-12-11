class compute_train::bacula {

include compute_train::params

$baculapackages = [ "bacula-client" , "bacula-libs", "bacula-common" ]


case $operatingsystemrelease {
    /^7.*/: {
             package { $baculapackages: ensure => "installed" }
             service { "bacula-fd":
                       ensure => running,
                       enable => true,
                       hasstatus => true,
                       hasrestart => true,
                       require => Package["bacula-client"],
                     }
            }
    /^8.*/: {
  
              package { $baculapackages: ensure => "purged" }

              package {"bareos-common":
                 provider => "rpm",
                 ensure   => installed,
                 source => "http://download.bareos.org/bareos/release/latest/CentOS_8/x86_64/bareos-common-19.2.7-2.el8.x86_64.rpm",
                      }  
 
              package {"bareos-filedaemon":
                 provider => "rpm",
                 ensure   => installed,
                 source => "http://download.bareos.org/bareos/release/latest/CentOS_8/x86_64/bareos-filedaemon-19.2.7-2.el8.x86_64.rpm",
                 require => Package["bareos-common"],
                      }  
  
              service { "bareos-fd":
                 ensure => running,
                 enable => true,
                 hasstatus => true,
                 hasrestart => true,
                 require => Package["bareos-filedaemon"],
                      }

            }
}
}

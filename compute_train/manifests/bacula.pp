class compute_train::bacula {

include compute_train::params

   $baculapackages = [ "bacula-client" ]
  
     package { $baculapackages: ensure => "installed" }
  
    
     service { "bacula-fd":
        ensure => running,
        enable => true,
        hasstatus => true,
        hasrestart => true,
        require => Package["bacula-client"],
      }


}

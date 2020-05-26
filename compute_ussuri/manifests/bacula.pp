class compute_ussuri::bacula {

include compute_ussuri::params

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

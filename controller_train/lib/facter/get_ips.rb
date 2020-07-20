Facter.add(:mgmt_ip) do
  setcode do
        Facter::Util::Resolution.exec("/sbin/ifconfig | /bin/awk -F ' *|:' '/inet /{print $3}' |/bin/fgrep '192.168.60' ")
  end
end

Facter.add(:data_ip) do
  setcode do
        Facter::Util::Resolution.exec("/sbin/ifconfig | /bin/awk -F ' *|:' '/inet /{print $3}' |/bin/fgrep '192.168.61' ")
  end
end



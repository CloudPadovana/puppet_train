Facter.add(:mgmtnw_ip) do
  setcode do
        Facter::Util::Resolution.exec("/usr/sbin/ip a | /usr/bin/awk '/inet / {print $2}' | /usr/bin/sed -e 's/\\/.*//g' | /usr/bin/grep 192.168.60")
  end
end

Facter.add(:datanw_ip) do
  setcode do
        Facter::Util::Resolution.exec("/usr/sbin/ip a | /usr/bin/awk '/inet / {print $2}' | /usr/bin/sed -e 's/\\/.*//g' | /usr/bin/grep 192.168.61")
  end
end



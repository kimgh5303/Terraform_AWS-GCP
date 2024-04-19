$ssh_config = <<-SCRIPT
  echo ">>>> root password <<<<<<"
  printf "qwe123\nqwe123\n" | passwd
  echo ">>>> ssh-config <<<<<<"
  sed -i "s/^#PasswordAuthentication yes/g" /etc/ssh/sshd_config
  sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
  systemctl restart sshd
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
#  config.vm.box_version = "20210603.0.0"
  config.vm.network "private_network", ip: "192.168.56.200"
  config.vm.network "forwarded_port", guest: 22, host: 50000, auto_correct: true, id: "ssh"
  config.vm.provision "shell", inline: $ssh_config
  config.vm.provider "virtualbox" do |vb1|
    vb1.memory = "2048"
    vb1.cpus = "2"
    vb1.linked_clone = true
  end
end
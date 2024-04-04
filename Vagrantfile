# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  boxes = [
    { :name => 'fedora-previous', :box => 'fedora/38-cloud-base' },
    { :name => 'fedora-newest', :box => 'fedora/39-cloud-base' },
    # { :name => 'rhel', :box => 'generic/rhel9' },
    { :name => 'centos-stream', :box => 'generic/centos9s' },
    { :name => 'rocky', :box => 'rockylinux/9' },
    { :name => 'opensuse', :box => 'opensuse/Tumbleweed.x86_64' },
    { :name => 'opensuse-leap', :box => 'opensuse/Leap-15.5.x86_64' },
    { :name => 'clear', :box => 'AntonioMeireles/ClearLinux' },
    { :name => 'debian', :box => 'generic/debian12' },
    { :name => 'ubuntu', :box => 'generic/ubuntu2310' },
  ]
  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.box = opts[:box]
      config.vm.hostname = opts[:name]
      config.vm.provider 'libvirt' do |libvirt|
        if opts[:name] == 'clear'
          libvirt.loader = '/usr/share/OVMF/OVMF_CODE.fd'
        end
        libvirt.machine_type = 'q35'
        libvirt.memory = 1024*2
        libvirt.cpus = 2
        libvirt.machine_virtual_size = 128
        libvirt.video_vram = 0
        libvirt.driver = 'kvm'
        
        libvirt.host = 'localhost'
        libvirt.uri = 'qemu:///system'

        libvirt.nested = true
        libvirt.cpu_mode = 'host-passthrough'
      end
      if opts[:name] == 'centos-stream'
        config.vm.provision 'shell',
          inline: 'rm -rf /var/cache/dnf'
      elsif 
        opts[:name] == 'centos'
        config.vm.provision 'shell',
          inline: <<-SCRIPT
          sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
          sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
          SCRIPT
      end
      if opts[:name] == boxes.last[:name]
        if ENV['ansible'] == 'local'
          config.vm.provision :ansible_local do |ansible|
            ansible.playbook = 'main.yml'
          end
        else
         # config.vm.provision :ansible do |ansible|
         #   ansible.playbook = 'user.yml'
         #   ansible.limit = 'all'
         # end
          config.vm.provision :ansible do |ansible|
            ansible.playbook = 'main.yml'
            ansible.limit = ENV['MACHINE'] ? ENV['MACHINE'] : 'all'
            #ansible.verbose = 'vvv'
            ansible.extra_vars = {
              #user: 'vagrant',
              # ansible_password = 'V@grant!',
            }
            ansible.skip_tags = 'virtools'
            ansible.host_vars = {
              "clear" => {
                "ansible_user"  =>  "clear",
                "ansible_password"  =>  "V@grant!"
              }
            }
          end
        end
      end
    end
  end
end

# -*- mode: ruby -*-
# vi: set ft=ruby :

SCALE=Integer(ENV['CPUS'] || 2)

Vagrant.configure('2') do |config|
  boxes = [
    ## Fedora
    { :name => 'fedora-newest', :box => 'fedora/41-cloud-base', :ovmf=> true },
    { :name => 'fedora-previous', :box => 'fedora/40-cloud-base', :ovmf=> true },
    ## RedHat
    { :name => 'rhel', :box => 'generic/rhel8' },
    { :name => 'centos-stream', :box => 'generic/centos9s', :ovmf=> false },
    { :name => 'rocky', :box => 'rockylinux/9', :ovmf=> true },
    { :name => 'alma', :box => 'almalinux/9', :ovmf=> true },
    { :name => 'oracle', :box => 'generic/oracle9', :ovmf=> false },
    ## SUSE
    { :name => 'opensuse', :box => 'opensuse/Tumbleweed.x86_64', :ovmf=> true },
    { :name => 'opensuse-leap', :box => 'opensuse/Leap-15.6.x86_64', :ovmf=> true },
    ## ClearLinux
    # { :name => 'clear', :box => 'AntonioMeireles/ClearLinux', :ovmf=> true },
    ## Debians
    # { :name => 'debian', :box => 'generic/debian12', :ovmf=> false },
    # { :name => 'ubuntu', :box => 'bento/ubuntu-24.04', :ovmf=> false },
  ]
  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.box = opts[:box]
      config.vm.hostname = opts[:name]

      config.vm.provider 'libvirt' do |libvirt|
        if opts[:ovmf]
          libvirt.loader = '/usr/share/OVMF/OVMF_CODE.fd'
        end
        libvirt.machine_type = 'q35'
        libvirt.driver = 'kvm'
        libvirt.memory = 1024*SCALE
        libvirt.cpus = SCALE
        libvirt.machine_virtual_size = 128
        # libvirt.video_vram = 0
        
        libvirt.host = 'localhost'
        libvirt.uri = 'qemu:///system'

        libvirt.nested = true
        libvirt.cpu_mode = 'host-passthrough'

        libvirt.default_prefix = ""
      end
      if opts[:name] == 'centos-stream'
        config.vm.provision 'shell',
          inline: 'rm -rf /var/cache/dnf'
      elsif 
        opts[:name] == 'fedora-newest'
        config.vm.provision 'shell',
          inline: <<-SCRIPT
          dnf install -y python3-libdnf5
          SCRIPT
      elsif opts[:name] == 'centos' || opts[:name] == 'centos-stream'
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
                "ansible_password"  =>  "V@grant!",
              },
              "fedora_newest" => {
                "ansible_skip_tags" => "",
              },
              "fedora_previous" => {
                "ansible_skip_tags" => "",
              }
            }
          end
        end
      end
    end
  end
end

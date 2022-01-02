Vagrant.configure('2') do |config|
  boxes = [
    { :name => 'fedora-previous', :box => 'fedora/34-cloud-base' },
    { :name => 'fedora-newest', :box => 'fedora/35-cloud-base' },
    { :name => 'centos', :box => 'centos/8' },
    { :name => 'centos-stream', :box => 'centos/stream8' },
    { :name => 'opensuse', :box => 'opensuse/Tumbleweed.x86_64' },
    { :name => 'opensuse-leap', :box => 'opensuse/Leap-15.3.x86_64' },
    { :name => 'clear', :box => 'AntonioMeireles/ClearLinux' },
    { :name => 'debian', :box => 'generic/debian11' },
    { :name => 'ubuntu', :box => 'generic/ubuntu2110' },
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
        libvirt.machine_virtual_size = 16
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
            ansible.limit = 'all'
            #ansible.verbose = 'vvv'
            ansible.extra_vars = {
              #user: 'vagrant',
            }
            ansible.skip_tags = 'virtools'

          end
        end
      end
    end
  end
end

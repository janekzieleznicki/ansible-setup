Vagrant.configure("2") do |config|
  boxes = [
    #{ :name => "debian", :box => "generic/debian10" },
    { :name => "ubuntu", :box => "generic/ubuntu2004" },
    { :name => "fedora", :box => "fedora/33-cloud-base" },
    #{ :name => "centos", :box => "centos/stream8" },
    #{ :name => "opensuse", :box => "opensuse/Tumbleweed.x86_64" },
    #{ :name => "opensuse-leap", :box => "opensuse/Leap-15.2.x86_64" },
    #{ :name => "clear", :box => "AntonioMeireles/ClearLinux" },
  ]
  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.box = opts[:box]
      config.vm.hostname = opts[:name]
      config.vm.provider 'libvirt' do |libvirt|
        if opts[:name] == 'clear'
          libvirt.loader = '/usr/share/OVMF/OVMF_CODE.secboot.fd'
        end
        libvirt.machine_type = 'q35'
        libvirt.memory = 2048
        libvirt.cpus = 2
        libvirt.video_vram = 0
        libvirt.driver = "kvm"
        libvirt.host = 'localhost'
        libvirt.uri = 'qemu:///system'

        libvirt.nested = true
        libvirt.cpu_mode = "host-passthrough"

        libvirt.management_network_name = 'custom_vagrant_managment_net'
        libvirt.management_network_address = '192.168.128.0/24'
      end
      if opts[:name] == 'centos'
        config.vm.provision 'shell',
          inline: "rm -rf /var/cache/dnf"
      end
      config.vm.provision "shell" do |s|
        ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_ed25519.pub").first.strip
        s.inline = <<-SHELL
          echo #{ssh_pub_key} >> .ssh/authorized_keys
          # echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
        SHELL
      end
      if opts[:name] == boxes.last[:name]
        if ENV['ansible'] == 'remote'
          config.vm.provision :ansible do |ansible|
            ansible.playbook = "user.yml"
            ansible.limit = "all"
          end
          config.vm.provision :ansible do |ansible|
            ansible.playbook = "main.yml"
            ansible.limit = "all"
          end
        else
          config.vm.provision :ansible_local do |ansible|
            ansible.playbook = 'main.yml'
          end
        end
      end
    end
  end
end

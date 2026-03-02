Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  config.vm.define "frontend" do |node|
    node.vm.hostname = "vm-frontend"
    node.vm.network "private_network", ip: "192.168.56.11"

    node.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
      vb.name = "lab-frontend"
    end

    node.vm.provision "shell", path: "provision-scripts/provision-frontend.sh"
  end

  config.vm.define "auth" do |node|
    node.vm.hostname = "vm-auth"
    node.vm.network "private_network", ip: "192.168.56.12"

    node.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
      vb.name = "lab-auth"
    end

    node.vm.provision "shell", path: "provision-scripts/provision-auth.sh"
  end

  config.vm.define "users" do |node|
    node.vm.hostname = "vm-users"
    node.vm.network "private_network", ip: "192.168.56.13"

    node.vm.provider "virtualbox" do |vb|
      vb.memory = 1536
      vb.cpus = 1
      vb.name = "lab-users"
    end

    node.vm.provision "shell", path: "provision-scripts/provision-users.sh"
  end

  config.vm.define "todos" do |node|
    node.vm.hostname = "vm-todos"
    node.vm.network "private_network", ip: "192.168.56.14"

    node.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
      vb.name = "lab-todos"
    end

    node.vm.provision "shell", path: "provision-scripts/provision-todos.sh"
  end

  config.vm.define "todos2" do |node|
    node.vm.hostname = "vm-todos2"
    node.vm.network "private_network", ip: "192.168.56.21"

    node.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
      vb.name = "lab-todos2"
    end

    node.vm.provision "shell", path: "provision-scripts/provision-todos.sh"
  end

  config.vm.define "redis" do |node|
    node.vm.hostname = "vm-redis"
    node.vm.network "private_network", ip: "192.168.56.15"

    node.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.cpus = 1
      vb.name = "lab-redis"
    end

    node.vm.provision "shell", inline: <<-SHELL
      apt-get update -y
      apt-get install -y docker.io
      systemctl enable docker
      systemctl start docker

      docker run -d \
        --name redis \
        -p 6379:6379 \
        redis:6
    SHELL
  end

  config.vm.define "log-processor" do |node|
    node.vm.hostname = "vm-log-processor"
    node.vm.network "private_network", ip: "192.168.56.16"

    node.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.cpus = 1
      vb.name = "lab-log-processor"
    end

    node.vm.provision "shell", path: "provision-scripts/provision-logproc.sh"
  end

  config.vm.define "haproxy" do |proxy|
    proxy.vm.hostname = "vm-haproxy"
    proxy.vm.network "private_network", ip: "192.168.56.20"

    proxy.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.cpus = 1
      vb.name = "lab-haproxy"
    end
  end

  config.vm.synced_folder ".", "/vagrant"
end
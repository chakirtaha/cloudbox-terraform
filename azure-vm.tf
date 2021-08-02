
resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_B2ms"
  #delete_os_disk_on_termination = true
  #delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
      name              = "myosdisk1"
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Standard_LRS"
    }

  os_profile {
      computer_name    = "${var.hostname}"
      admin_username   = "${var.ssh_user}"
      admin_password   = "${var.ssh_password}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }


  provisioner "remote-exec" {
    inline = [
       "echo 'Wait until SSH is ready'",
       "sudo apt-get update -y",
       "sudo apt-get upgrade -y",
       "sudo apt-add-repository --yes ppa:ansible/ansible",
       "sudo apt-get update -y",
       "sudo apt-get install ansible -y",
  ]

    connection {
        host     = "${azurerm_public_ip.main.fqdn}"
        type     = "ssh"
        user     = "${var.ssh_user}"
        password = "${var.ssh_password}"
    }
  }
  provisioner "file" {
      source      = "playbook.yml"
      destination = "/tmp/playbook.yml"

      connection {
          host     = "${azurerm_public_ip.main.fqdn}"
          type     = "ssh"
          user     = "${var.ssh_user}"
          password = "${var.ssh_password}"


    }
  }

    provisioner "remote-exec" {
      inline = [

         "sudo mv /tmp/playbook.yml /etc/ansible/",
         "sudo chmod 777 /etc/ansible/playbook.yml",
         "sudo apt-get update",
         "sudo apt-get -y install python3-pip",
         "cd /etc/ansible",
         "ansible-playbook playbook.yml"

    ]

      connection {
          host     = "${azurerm_public_ip.main.fqdn}"
          type     = "ssh"
          user     = "${var.ssh_user}"
          password = "${var.ssh_password}"
      }
    }

provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"

    connection {
        host     = "${azurerm_public_ip.main.fqdn}"
        type     = "ssh"
        user     = "${var.ssh_user}"
        password = "${var.ssh_password}"

      }
    }

provisioner "remote-exec" {
    inline = [
         "export GITLAB_HOME=/srv/gitlab",
         "sudo docker run --detach    --hostname portailcloudbox.westeurope.cloudapp.azure.com   --publish 443:443 --publish 80:80 --publish 23:23  --name gitlab   --restart always    --volume $GITLAB_HOME/config:/etc/gitlab    --volume $GITLAB_HOME/logs:/var/log/gitlab    --volume $GITLAB_HOME/data:/var/opt/gitlab    gitlab/gitlab-ee:latest",
         "sudo docker ps",
         "sudo docker exec -it gitlab bash",
         "gitlab-rails console",
         "sudo date",
         "user = User.find_by_username 'root'",
         "user.password = 'Password123'",
         "user.password_confirmation = 'Password123'",
         "user.save!"


       ]

    connection {
        host     = "${azurerm_public_ip.main.fqdn}"
        type     = "ssh"
        user     = "${var.ssh_user}"
        password = "${var.ssh_password}"
    }
  }

}

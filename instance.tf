provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "flaming_elk" {
  ami           = "ami-51537029"
  key_name      = "ppuppet"
  instance_type = "m4.large"
  subnet_id		= "subnet-c9bfb78f"
  vpc_security_group_ids = ["${aws_security_group.flaming_elk_sg.id}"]
  key_name = "${var.key_name}"
  tags {
		Name = "${var.hostname}"
  }
#  user_data = <<-EOF
#                  #!/bin/bash
#                  sudo apt-get install -y openjdk-8-jdk python-setuptools apt-transport-https
#                  sudo wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
#                  sudo echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
#                  EOF
  user_data = <<-EOF
                  #cloud-config
                  repo_update: true
                  repo_upgrade: all
                  manage_etc_hosts: true
                  fqdn: "${var.fqdn}"
                  runcmd:
                   - sudo wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
                  apt_sources:
                   - source: deb https://artifacts.elastic.co/packages/6.x/apt stable main

                  packages:
                   - default-jre
                   - s3cmd
                  runcmd:
                   - sudo apt install -y elasticsearch logstash kibana --allow-unauthenticated
                  EOF
  provisioner "file" {
      source      = "elasticsearch/elasticsearch.yml"
      destination = "/tmp/elasticsearch.yml"
      connection {
          user = "ubuntu"
          type = "ssh"
          private_key = "${file(var.pvt_key)}"
          timeout = "2m"
    }
  }
#  provisioner "remote-exec" {
#    inline = [
#      "sudo mkdir /etc/elasticsearch",
#      "sudo cp /tmp/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml",
#      "sudo service elasticsearch start"
#    ]
#    connection {
#          user = "ubuntu"
#          type = "ssh"
#          private_key = "${file(var.pvt_key)}"
#          timeout = "2m"
#    }
#  }
}

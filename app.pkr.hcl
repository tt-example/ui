locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "name" {
  type    = string
  default = "tt-ui"
}

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name = "${var.name}-${local.timestamp}"
  tags = {
    Application = var.name
  }
  instance_type = "t2.micro"
  region        = "eu-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = var.name
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source      = "build"
    destination = "/tmp/build"
  }

  provisioner "file" {
    source      = "app.config.json"
    destination = "/tmp/app.config.json"
  }

  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    script = "app-init.sh"
  }

}

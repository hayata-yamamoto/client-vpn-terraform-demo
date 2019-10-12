variable "region" {
  default = "ap-northeast-1"
}

variable "availability_zone" {
  default = "ap-northeast-1a"
}

variable "instance_info" {
  type = "map"
  default = {
    ami           = "ami-0c6dcc2b75586bc5d"
    instance_type = "t2.small"
  }

}

variable "cidr_blocks" {
  type = "map"
  default = {
    vpc        = "10.0.0.0/16"
    subnet     = "10.0.0.0/24"
    global     = "0.0.0.0/0"
    client_vpn = "100.0.0.0/16"
  }
}

variable "my_cidr_block" {}

variable "ssh_keyname" {}

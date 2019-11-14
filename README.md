# Client VPN Terraform Demo

Terraform Version 

```bash
$ terraform --version
Terraform v0.12.2
+ provider.aws v2.16.0
```

## Certification

```bash 
$ git clone https://github.com/OpenVPN/easy-rsa.git
$ cd easy-rsa/easyrsa3
$ ./easyrsa init-pki
$ ./easyrsa build-ca nopass
$ ./easyrsa build-server-full server nopass
$ ./easyrsa build-client-full client1.domain.tld nopass

$ cp pki/ca.crt /custom_folder/
$ cp pki/issued/server.crt /custom_folder/
$ cp pki/private/server.key /custom_folder/
$ cp pki/issued/client1.domain.tld.crt /custom_folder
$ cp pki/private/client1.domain.tld.key /custom_folder/
$ cd /custom_folder/

```

## ACM

```
# Import server certification
$ aws acm import-certificate --certificate file://server.crt --private-key file://server.key --certificate-chain file://ca.crt --region region

# Import client certification
$ aws acm import-certificate --certificate file://client1.domain.tld.crt --private-key file://client1.domain.tld.key --certificate-chain file://ca.crt --region region
```


## Create VPN endpoint and demo network

First of all, you just execute following commands. After that, terraform ask you your CIDR block and ssh keyname. If you've not make ssh key yet, I recommend you to create a ssh key before doing below.

```bash 
$ terraform init
$ terraform plan 
$ terraform apply 
```

And then open the AWS console. Set authorization and route table on ClientVPN. 


## OpenVPN Setting

After finishing the above, you can donwload configuration file from ClientVPN. 

Open your configuration file, and add two sentences like below, 

```
# your-configuration-file.vpn
...

cert /path/to/client1.domain.tld.crt
key /path/to/client1.domain.tld.key
```

Read configuration file by VPN client ex.) OpenVPN, Tunnelblick

## Connect Jupyter Server

Connect your instance. you can check global ip adress on Terraform outputs.

```sh
$ ssh -i keyname ubuntu@instance-global-ip
```

Since instance you created is Deep Learning AMI, all you have to do is launch jupyter server. 
In this document, we allow all users to connect this. However, you have to consider your workspace configurations if you use.

```sh
$ jupyter notebook --no-browser --NotebookApp.token=""
$ ssh -i keyname ubuntu@instance-private-ip -L 8888:localhost:8888 -N 
```

You can look jupyter UI on [localhost:8888](http://localhost:8888/tree)

## Reference

- [ClientVPN](https://docs.aws.amazon.com/ja_jp/vpn/latest/clientvpn-admin/what-is.html)

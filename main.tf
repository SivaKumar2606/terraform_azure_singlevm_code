
# Configure the Microsoft Azure Provider

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
    client_id     = "${var.access_key}"
    client_secret = "${var.secret_key}"
    subscription_id = "${var.sub_id}"
    tenant_id = "${var.tenant_id}"
    features {}
}

# Create a resource group if it doesn't exist

resource "azurerm_resource_group" "myterraformgroup" {
    name     = "${var.rg_name}"
    location = "${var.loc}"

    tags = {
        environment = "${var.env}"
    }
}

# Create virtual network

resource "azurerm_virtual_network" "myterraformvnet" {
    name                = "${var.vnet_name}"
    address_space       = ["${var.vnet_address}"]
    location            = azurerm_resource_group.myterraformgroup.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
        environment = "${var.env}"
    }
}

# Create subnet1
resource "azurerm_subnet" "myterraformsubnet1" {
    name                 = "${var.subnet1_name}"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformvnet.name
    address_prefixes     = ["${var.subnet1_prefix}"]
}

# Create subnet2
resource "azurerm_subnet" "myterraformsubnet2" {
    name                 = "${var.subnet2_name}"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformvnet.name
    address_prefixes     = ["${var.subnet2_prefix}"]
}

# Create subnet3
resource "azurerm_subnet" "myterraformsubnet3" {
    name                 = "${var.subnet3_name}"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformvnet.name
    address_prefixes     = ["${var.subnet3_prefix}"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                    = "${var.mypip}"
    location                = azurerm_resource_group.myterraformgroup.location
    resource_group_name     = azurerm_resource_group.myterraformgroup.name
    allocation_method       = "Dynamic"

    tags = {
        environment = "${var.env}"
    }
}

# Create Network Security Group and rule

resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "${var.nsg_name}"
    location            = azurerm_resource_group.myterraformgroup.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "${var.env}"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = azurerm_resource_group.myterraformgroup.location
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet1.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = "${var.env}"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = azurerm_resource_group.myterraformgroup.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "${var.env}"
    }
}

# # Create (and display) an SSH key
# resource "tls_private_key" "example_ssh" {
#   algorithm = "RSA"
#   rsa_bits = 4096
# }
# output "tls_private_key" { 
#     value = tls_private_key.example_ssh.private_key_pem 
#     sensitive = true
# }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "${var.vm_name}"
    location              = azurerm_resource_group.myterraformgroup.location
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "${var.vm_size}"
    admin_username        = "${var.username}"
    admin_password        = "${var.password}"
    disable_password_authentication = false

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "${var.publisher}"
        offer     = "${var.offer}"
        sku       = "${var.sku}"
        version   = "latest"
    }

    # computer_name  = "myvm"
    # admin_username = "azureuser"
    # disable_password_authentication = true

    # admin_ssh_key {
    #     username       = "azureuser"
    #     public_key     = tls_private_key.example_ssh.public_key_openssh
    # }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "${var.env}"
    }
}
terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "3.83.0"
  }
}
}
provider "azurerm" {
    features {}
    skip_provider_registration = true 
    subscription_id = var.subscription_id
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
}
resource "azurerm_resource_group" "tf_rg" {
    name ="tf_rg"
    location="east us"
  
}
resource "azurerm_virtual_network" "tf_vnet" {
    name="tf_vnet"
    resource_group_name=azurerm_resource_group.tf_rg.name
    location= azurerm_resource_group.tf_rg.location
    address_space = ["10.0.0.0/16"]
  
}
resource "azurerm_subnet" "tf_subnet1" {
    name="tf_subnet1"
    resource_group_name=azurerm_resource_group.tf_rg.name
    virtual_network_name= azurerm_virtual_network.tf_vnet.name
    address_prefixes = ["10.0.1.0/25"]
  
}
resource "azurerm_subnet" "tf_subnet2" {
    name = "tf_subnet2"
    resource_group_name = azurerm_resource_group.tf_rg.name
    virtual_network_name = azurerm_virtual_network.tf_vnet.name
    address_prefixes = [ "10.0.2.0/25" ]
  
}
resource "azurerm_subnet" "subnet3" {
    name = "subnet"
    resource_group_name = azurerm_resource_group.tf_rg.name
    virtual_network_name = azurerm_virtual_network.tf_vnet.name
    address_prefixes = [ "10.0.3.0/25" ]
  
}
resource "azurerm_public_ip" "tfvm_pip" {
    name = "tfvm_pip"
    resource_group_name = azurerm_resource_group.tf_rg.name
    location = azurerm_resource_group.tf_rg.location
    allocation_method = "Static"
  
}
resource "azurerm_network_interface" "tfvmn_interface" {
    name = "tfvmn_interface"
    location = azurerm_resource_group.tf_rg.location
    resource_group_name = azurerm_resource_group.tf_rg.name
    ip_configuration {
      name = "ipconfig"
      subnet_id = azurerm_subnet.tf_subnet1.id
      public_ip_address_id =azurerm_public_ip.tfvm_pip.id
      private_ip_address_allocation= "Dynamic"
    }
}
resource "azurerm_linux_virtual_machine" "webserver" {
    name = "webserver"
    resource_group_name = azurerm_resource_group.tf_rg.name
    location = azurerm_resource_group.tf_rg.location
    size ="Standard_F2"
    admin_username = "appadmin"
    network_interface_ids = [azurerm_network_interface.tfvmn_interface.id]
    admin_ssh_key {
        username = "appadmin"
        public_key = file("~/.ssh/id_rsa.pub")
    }

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts"
        version = "latest"
    }
}
resource "azurerm_public_ip" "public_ip2" {
    name = "public_ip2"
    resource_group_name = azurerm_resource_group.tf_rg.name
    location = azurerm_resource_group.tf_rg.location
    allocation_method = "Static"
  
}
resource "azurerm_network_interface" "nw_interface2" {
    name = "nw_interface2"
    resource_group_name = azurerm_resource_group.tf_rg.name
    location = azurerm_resource_group.tf_rg.location
    ip_configuration {
      name = "ip_config2"
      subnet_id = azurerm_subnet.tf_subnet2.id
      public_ip_address_id = azurerm_public_ip.public_ip2.id
      private_ip_address_allocation = "Dynamic"
    }
  
}
resource "azurerm_linux_virtual_machine" "appserver" {
    name = "appserver"
    resource_group_name = azurerm_resource_group.tf_rg.name
    location = azurerm_resource_group.tf_rg.location
    size = "Standard_F2"
    admin_username = "appadmin"
    network_interface_ids = [ azurerm_network_interface.nw_interface2.id]
    admin_ssh_key {
      username = "appadmin"
      public_key = file("C:/Users/konas/.ssh/id_rsa.pub")
    }

    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-jammy"
      sku = "22_04-lts"
      version = "latest"
    }
}
resource "azurerm_public_ip" "public_ip3" {
    name = "public_ip3"
    resource_group_name = azurerm_resource_group.tf_rg.name
    location = azurerm_resource_group.tf_rg.location
    allocation_method ="Static"
  
}
resource "azurerm_network_interface" "nw_interface3" {
  name = "nw_interface3"
  resource_group_name = azurerm_resource_group.tf_rg.name
  location = azurerm_resource_group.tf_rg.location
  ip_configuration {
    name = "ip_congig3"
    subnet_id = azurerm_subnet.subnet3.id
    public_ip_address_id = azurerm_public_ip.public_ip3.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_linux_virtual_machine" "dbserver" {
    name = "dbserver"
    resource_group_name = azurerm_resource_group.tf_rg.name
    location = azurerm_resource_group.tf_rg.location
    size = "Standard_F2"
    admin_username = "appadmin"
    network_interface_ids = [azurerm_network_interface.nw_interface3.id] 
    admin_ssh_key {
      username = "appadmin"
      public_key = file("~/.ssh/id_rsa.pub")
    }
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-jammy"
      sku = "22_04-lts"
      version = "latest"
    }
}
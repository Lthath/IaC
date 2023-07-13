terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.57.0"
    }
  }


  
  backend "azurerm" {
    resource_group_name    = var.backendstrgrg
    storage_account_name   = var.backendstrg
    container_name         = var.backendctn
    key                    = var.backendstrgkey
  }

}
provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

resource "azurerm_resource_group" "maleo-rg" {
  name     = var.resourcegroup_name
  location = var.location
}

resource "azurerm_virtual_network" "maleo-vnet" {
  name                = var.virtual_network_name
  address_space       = ["10.1.0.0/26"]
  location            = azurerm_resource_group.maleo-rg.location
  resource_group_name = azurerm_resource_group.maleo-rg.name
}

resource "azurerm_subnet" "maleo-subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.maleo-rg.name
  virtual_network_name = azurerm_virtual_network.maleo-vnet.name
  address_prefixes     = ["10.1.0.0/29"]
}

resource "azurerm_public_ip" "maleo-publicip" {
  name                = "ad-publicip"
  location            = azurerm_resource_group.maleo-rg.location
  resource_group_name = azurerm_resource_group.maleo-rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "maleo-nsg" {
  name                = "ad-nsg"
  location            = azurerm_resource_group.maleo-rg.location
  resource_group_name = azurerm_resource_group.maleo-rg.name
}
resource "azurerm_network_security_rule" "rdp_ssh_inbound" {
  name                        = "Allow_RDP_SSH_Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["3389", "22"]
  source_address_prefixes     = ["*"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.maleo-rg.name
  network_security_group_name = azurerm_network_security_group.maleo-nsg.name
}

resource "azurerm_network_interface" "maleo-nic" {
  name                      = "ad-nic"
  location                  = azurerm_resource_group.maleo-rg.location
  resource_group_name       = azurerm_resource_group.maleo-rg.name

  ip_configuration {
    name                          = "ad-ipconfig"
    subnet_id                     = azurerm_subnet.maleo-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.maleo-publicip.id
  }
}

resource "azurerm_virtual_machine" "maleo-vm" {
  name                  = var.virtual_machine_name
  location              = azurerm_resource_group.maleo-rg.location
  resource_group_name   = azurerm_resource_group.maleo-rg.name
  network_interface_ids = [azurerm_network_interface.maleo-nic.id]

  vm_size              =  var.virtual_machine_size
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.virtual_machine_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.virtual_machine_name
    admin_username = var.virtual_machine_username
    admin_password = var.virtual_machine_password
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent        = true
  }

  tags = {
    environment = "Production"
  }
}
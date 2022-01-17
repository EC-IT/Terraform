data "azurerm_subscription" "current" {}

resource "azurerm_policy_definition" "policy" {
  name         = var.policy_name
  policy_type  = "Custom"
  mode         = "All"
  display_name = var.policy_name

  metadata = <<METADATA
    {
    "category": "${var.policy_category}"
    }

METADATA

  policy_rule = var.policy_rule

  parameters = <<PARAMETERS
    {}
PARAMETERS

}

resource "azurerm_subscription_policy_assignment" "policy_assignment" {
  name                 = "${var.policy_name}-assignment"
  policy_definition_id = azurerm_policy_definition.policy.id
  subscription_id      = data.azurerm_subscription.current.id
}
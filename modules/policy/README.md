## Example

```terraform
locals {

  policys = [
    ########## SA_TLS_minimum ##########
    { 
        name= "SA_TLS_minimum", 
        category="PROD", 
        rule =<<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Storage/storageAccounts"
          },
          {
            "not": {
              "field": "Microsoft.Storage/storageAccounts/minimumTlsVersion",
              "equals": "TLS1_2"
            }
          }
        ]
      },
      "then": {
        "effect": "deny"
      }
    }
POLICY_RULE
    },
  ]
}

module "NPE-POLICY" {
  for_each = {for i, v in local.policys:  i => v}
  source                 = "../modules/policy"
  policy_name            = each.value.name
  policy_category        = each.value.category
  policy_rule            = each.value.rule
}


```

module "SECU-POLICY" {
  for_each = {for i, v in local.policys:  i => v}
  source                 = "../modules/policy"
  policy_name            = each.value.name
  policy_category        = each.value.category
  policy_rule            = each.value.rule
}

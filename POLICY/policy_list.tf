locals {

  policys = [
    ########## SECURITY_SA_TLS_minimum ##########
    { 
        name= "SECURITY_SA_TLS_minimum", 
        category="SECURITY", 
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
    ########## SECURITY_SA_HTTPS_only ##########
    { 
        name= "SECURITY_SA_HTTPS_only", 
        category="SECURITY", 
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
              "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
              "equals": true
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
    ########## SECURITY_SA_BlobPublicAccess_disable ##########
    { 
        name= "SECURITY_SA_BlobPublicAccess_disable", 
        category="SECURITY", 
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
              "field": "Microsoft.Storage/storageAccounts/allowBlobPublicAccess",
              "equals": false
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
    ########## SECURITY_APP_TLS_minimum ##########
    { 
        name= "SECURITY_APP_TLS_minimum", 
        category="SECURITY", 
        rule =<<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Web/sites/config"
          },
          {
            "not": {
              "field": "Microsoft.Web/sites/config/minTlsVersion",
              "equals": "1.2"
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
    ########## SECURITY_APP_HTTPS_only ##########
    { 
        name= "SECURITY_APP_HTTPS_only", 
        category="SECURITY", 
        rule =<<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Web/sites"
          },
          {
            "not": {
              "field": "Microsoft.Web/sites/httpsOnly",
              "equals": true
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
    ########## SECURITY_SQL_TLS_minimum ##########
    { 
        name= "SECURITY_SQL_TLS_minimum", 
        category="SECURITY", 
        rule =<<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Sql/servers"
          },
          {
            "not": {
              "field": "Microsoft.Sql/servers/minimalTlsVersion",
              "equals": "1.2"
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
    ########## SECURITY_PostgreSQL_TLS_minimum ##########
    { 
        name= "SECURITY_PostgreSQL_TLS_minimum", 
        category="SECURITY", 
        rule =<<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.DBforPostgreSQL/servers"
          },
          {
            "not": {
              "field": "Microsoft.DBforPostgreSQL/servers/minimalTlsVersion",
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
    ########## SECURITY_PostgreSQL_SSL_enforce ##########
    { 
        name= "SECURITY_PostgreSQL_SSL_enforce", 
        category="SECURITY", 
        rule =<<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.DBforPostgreSQL/servers"
          },
          {
            "not": {
              "field": "Microsoft.DBforPostgreSQL/servers/sslEnforcement",
              "equals": "Enabled"
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
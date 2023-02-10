# acme-fitness-tap
ACME fitness store build and deployment configuration for TAP 


Execute this script 
```
./install-acme-fitness-on-tap.sh
```

VERIFY CLIENT REGISTRATION
```
CLIENT_ID=$(kubectl get secret acme-fitness-client-registration -n acme -o jsonpath="{.data.client-id}" | base64 -d) 
CLIENT_SECRET=$(kubectl get secret acme-fitness-client-registration -n acme -o jsonpath="{.data.client-secret}" | base64 -d) 
ISSUER_URI=$(kubectl get secret acme-fitness-client-registration -n acme -o jsonpath="{.data.issuer-uri}" | base64 -d) 
curl -XPOST "$ISSUER_URI/oauth2/token?grant_type=client_credentials&scope=messages.read" -u "$CLIENT_ID:$CLIENT_SECRET"
```

`kubectl get clientregistration -A`
```
NAMESPACE   NAME                               STATUS
acme        acme-fitness-client-registration   Ready
```
 

Get claim reference
`tanzu service claim list`
Or, the updated command:
`tanzu service resource-claim list -A`
```
NAMESPACE  NAME                 READY  REASON  
  acme       appsso-acme-fitness  True   Ready  
```

`tanzu service class-claims get appsso-acme-fitness -n acme`

Troubleshooting
Bind to workload test 
```
tanzu apps workload create tanzu-java-web-app \
--git-repo https://github.com/sample-accelerators/tanzu-java-web-app \
--git-branch main \
--type web \
--label app.kubernetes.io/part-of=tanzu-java-web-app \
--annotation autoscaling.knative.dev/minScale=1 \
--service-ref="appsso-acme-fitness=services.apps.tanzu.vmware.com/v1alpha1:ResourceClaim:appsso-acme-fitness"
```

testing
```
curl -XPOST "$ISSUER_URI/oauth2/token?grant_type=client_credentials&scope=messages.read" -u "$CLIENT_ID:$CLIENT_SECRET" 
{"access_token":"eyJraWQiOiJhcHBzc28tYWNtZS1maXRuZXNzLXNpZ25pbmcta2V5IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJhY21lX2FjbWUtZml0bmVzcy1jbGllbnQtcmVnaXN0cmF0aW9uIiwiYXVkIjoiYWNtZV9hY21lLWZpdG5lc3MtY2xpZW50LXJlZ2lzdHJhdGlvbiIsIm5iZiI6MTY3NTU0MTc2OCwic2NvcGUiOlsibWVzc2FnZXMucmVhZCJdLCJpc3MiOiJodHRwOlwvXC9hcHBzc28tYWNtZS1maXRuZXNzLmFjbWUudGFwLnN5bmFibGUuaW8iLCJleHAiOjE2NzU1NDIwNjgsImlhdCI6MTY3NTU0MTc2OH0.C0NVzzOOXKMyX3PmRb7-yXW0OcPbk8a3p4bHCqN7kRN0zYkRlm7mn4wNQg5RewiL6NUbvs4iGBYixKpoylfJ3Ic_nYb5YTrgCXX7L1O70V-6W0I0PGFPLkf_FgGWE6s46yDbyg9AvEqc8fcM88qfMD-qW8rhf0-6ln2qtQtJFZFDJ0l76aNc-uHr3nVpezMsd9x7ZwkMRqbIUUUZ9nNrpMsho-KlpKzOyVUqc-DY2ZAp2w615qgTEyeltM-55fJRYa8WRrPPKyx6CflAIwxKZeODPq1WMuG9FDofNcYyeqeXJx1mjJFAjzFyW_rbM0TfY6keTO8YX0udQYquOJgzvA","scope":"messages.read","token_type":"Bearer","expires_in":299}%        

curl -k https://acme-cart.acme.tap.synable.io/cart/items/eric  -H "Accept: application/json" -H "Authorization: Bearer eyJraWQiOiJhcHBzc28tYWNtZS1maXRuZXNzLXNpZ25pbmcta2V5IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJhY21lX2FjbWUtZml0bmVzcy1jbGllbnQtcmVnaXN0cmF0aW9uIiwiYXVkIjoiYWNtZV9hY21lLWZpdG5lc3MtY2xpZW50LXJlZ2lzdHJhdGlvbiIsIm5iZiI6MTY3NTU0MTIzMSwic2NvcGUiOlsibWVzc2FnZXMucmVhZCJdLCJpc3MiOiJodHRwOlwvXC9hcHBzc28tYWNtZS1maXRuZXNzLmFjbWUudGFwLnN5bmFibGUuaW8iLCJleHAiOjE2NzU1NDE1MzEsImlhdCI6MTY3NTU0MTIzMX0.nBqIvgmBwRJ2P8LkaM30tt3mg6Gl6Ft1lBFTQM2x1WxSoCyhEnCnQLO_-tDm5DvT_oi5fbYG6aiL-5E5QZvyN_-V3b6NNPwVibf00WjHLKQMOAxaKIEOrKdc4fZ-EOt9go_mVpPvokyySgsabbA0jSkPJY5jMQIl9cGxbdCqUiFSgCCWytFmiRiJVgemRVGxK2XPtTieTc5M7o3lftSqogXN2ktS3RrppwXdPtrrRZd-PKuGtJ_nmuijGIfiEJVRub_gSp6BbBF3o3289EaHCYMlkKkaxlwgPstO7YVHqvFrjtOuNGRNlxSECyIis0AGc3xhcgAAB_xSTpchSZOi1g"
```
Testing with env variables
```
export ACCESS_TOKEN=$(curl -XPOST "$ISSUER_URI/oauth2/token?grant_type=client_credentials&scope=messages.read" -u "$CLIENT_ID:$CLIENT_SECRET" | jq '.access_token')

curl -k https://acme-cart.acme.tap.synable.io/cart/items/eric  -H "Accept: application/json" -H "Authorization: Bearer $ACCESS_TOKEN"
```

Open in browser to verify catalog
https://acme-catalog.acme.tap.synable.io/products


testing identity???

https://acme-identity.acme.tap.synable.io/whoami

curl -k https://acme-identity.acme.tap.synable.io/whoami  -H "Accept: application/json" -H "Authorization: Bearer $ACCESS_TOKEN"


.PHONY: plan


plan: 
	terraform plan --out plan && terraform show -json plan > plan.json  
# If the score is > blast radius this will return false 
auth: plan
	opa exec --decision terraform/analysis/auth --bundle policies/ plan.json | jq '.result[0].result' | grep -i true

apply: plan auth	
	terraform apply

init:	
	terraform init

# These two functions should be used to debug opa
eval-auth: plan
	opa eval --bundle policies/ --input plan.json --format pretty 'data.terraform.analysis.auth' --fail-defined

eval-score: plan
	opa eval --bundle policies/ --input plan.json --format pretty 'data.terraform.analysis.score'

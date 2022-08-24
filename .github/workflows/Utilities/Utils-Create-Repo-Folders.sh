# For Creating Git Config in Parameters file for ADO
#"personal_access_token": "yhdjjk6kcmmv6zcfowmsh6pmcre3jbstwbk5sarxcwtutmlyu5ha",
#"git_username": "ciaranh@microsoft.com",
#"git_provider": "azureDevOpsServices"

echo "Test Application ID"
echo $param_dbxSPNAppID



echo "Ingest JSON File"
JSON=$( jq '.' .github/workflows/Pipeline_Param/$environment.json)
#echo "${JSON}" | jq


for row in $(echo "${JSON}" | jq -r '.Git_Configuration[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }
    echo $PAT_GIT
    JSON_STRING=$( jq -n -c \
                --arg pat "$PAT_GIT" \
                --arg gu "$(_jq '.git_username')" \
                --arg gp "$(_jq '.git_provider')"  \
                --arg br "$(_jq '.branch')"  \
                '{personal_access_token: $pat,
                git_username: $gu,
                git_provider: $gp,
                branch: $br}' )


    CREATE_GIT_CREDENTIALS_RESPONSE=$(curl -X POST -H "Authorization: Bearer $TOKEN" \
                -H "X-Databricks-Azure-SP-Management-Token: $MGMT_ACCESS_TOKEN" \
                -H "X-Databricks-Azure-Workspace-Resource-Id: $WORKSPACE_ID" \
                -H 'Content-Type: application/json' \
                -d $JSON_STRING \
                https://$DATABRICKS_INSTANCE/api/2.0/git-credentials )

    echo "Git Credentials Response...."
    echo $CREATE_GIT_CREDENTIALS_RESPONSE
done

for row in $(echo "${JSON}" | jq -r '.Repo_Configuration[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }

    PATH="$(_jq '.path')"
    echo "We Will Create The $PATH Folder By Appending It To The User Folder $param_dbxSPNAppID In Databricks REPOS "
    echo "The User Folder $param_dbxSPNAppID is Protected And Is Linked To The DevOps Agent SP Which Is The User."

    echo "Creating /Repos/$param_dbxSPNAppID/$PATH Fodler In Repos ... "
    ABSOLUTE_FILE_PATH="/Repos/$param_dbxSPNAppID/$PATH"
    echo $ABSOLUTE_FILE_PATH

    JSON_STRING=$( jq -n -c \
                --arg url "$(_jq '.url')" \
                --arg provider "$(_jq '.provider')" \
                '{url: $url,
                provider: $provider,
                path: $ABSOLUTE_FILE_PATH}' )

    CREATE_REPO_RESPONSE=$(curl -X POST -H "Authorization: Bearer $TOKEN" \
                -H "X-Databricks-Azure-SP-Management-Token: $MGMT_ACCESS_TOKEN" \
                -H "X-Databricks-Azure-Workspace-Resource-Id: $WORKSPACE_ID" \
                -H 'Content-Type: application/json' \
                -d $JSON_STRING \
                https://$DATABRICKS_INSTANCE/api/2.0/repos )

    echo "Repo Response"
    echo $CREATE_REPO_RESPONSE
done




































#git_credentials=$(curl -X POST -H "Authorization: Bearer $token" \
#        -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
#        -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
#        -H 'Content-Type: application/json' \
#        -d $JSON_STRING
#        '{
#        "personal_access_token": "yhdjjk6kcmmv6zcfowmsh6pmcre3jbstwbk5sarxcwtutmlyu5ha", 
#        "git_username": "ciaranh@microsoft.com", 
#        "git_provider": "azureDevOpsServices"
#        }' https://$workspaceUrl/api/2.0/git-credentials )




#git_credentials=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
#'{
#"personal_access_token": "yhdjjk6kcmmv6zcfowmsh6pmcre3jbstwbk5sarxcwtutmlyu5ha", 
#"git_username": "ciaranh@microsoft.com", 
#"git_provider": "azureDevOpsServices"
#}' https://$workspaceUrl/api/2.0/git-credentials )

#echo $git_credentials 

## The Section CREATES The Repos --> 3 Folders 'Production, Staging and Test' in the DBX Repo for the SP. This will be locked Down 
## When changes are merged into each branch, an automated pipeline run will update the repo.
## This will ensure that the branch for the testing /production repo is up to date when we run jobs on it.


#create_repo_response=$(curl -X POST -H "Authorization: Bearer $token" \
#                -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
#                -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
#                -H 'Content-Type: application/json' -d \
#'{
#"url": "https://dev.azure.com/ciaranh0658/_git/devopsTemplates", 
#"provider": "azureDevOpsServices",
#"path": "/Repos/ce79c2ef-170d-4f1c-a706-7814efb94898/Development"
#}' https://$workspaceUrl/api/2.0/repos )

#echo $create_repo_response

#create_repo_response=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
#'{
#"url": "https://dev.azure.com/ciaranh0658/_git/devopsTemplates", 
#"provider": "azureDevOpsServices",
#"path": "/Repos/ce79c2ef-170d-4f1c-a706-7814efb94898/Production"
#}' https://$workspaceUrl/api/2.0/repos )

#echo $create_repo_response

#create_repo_response=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
#'{
#"url": "https://dev.azure.com/ciaranh0658/_git/devopsTemplates", 
#"provider": "azureDevOpsServices",
#"path": "/Repos/ce79c2ef-170d-4f1c-a706-7814efb94898/Staging"
#}' https://$workspaceUrl/api/2.0/repos )

#echo $create_repo_response

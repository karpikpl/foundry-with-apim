# About

This is transcript for Foundry AI Gateway setup.

## Scenario

In Foundry portal, navigate to Operate -> Admin -> AI Gateway.
Add Existing AI Gateway.

## Demo Flow

- 0:00 - 0:02 Foundry welcome screen, click Operate
- 0:02 - 0:07 Go to Admin, than AI Gateway
- 0:07 - 0:10 Click AI AI Gateway button, modal shows up with Create new/Use existing options.
- 0:10 - 0:21 Select Foundry, Select Existing gateway
- 0:21 - 0:28 Look at existing, onboarded AI Gateway - all foundry projects have green enabled tag. Token Management tab is visible.


## Notes

- Use the name "Foundry" instead of "Azure AI Foundry".
- Foundry uses "account" and "project" terminology.
- APIM Basic v2 does not support autoscaling (manual scaling up to 10 units only).
- Foundry APIM Connection is described [here](https://github.com/microsoft-foundry/foundry-samples/blob/main/infrastructure/infrastructure-setup-bicep/01-connections/apim-and-modelgateway-integration-guide.md)
- Goal is to allow "Foundry Agent Service" to use models from APIM.
- Only the `Transcript` section is going to be read in the video.

## Transcript

### Part 1 - Foundry Portal

[Notes]
Length: 28s
- [0-2s] Foundry welcome screen, user clicks Operate.
- [2-7s] Navigate to Admin, then AI Gateway.
- [7-10s] Click AI Gateway button, modal appears with Create new / Use existing options.
- [10-21s] Select Foundry account, select existing gateway.
- [21-28s] View onboarded AI Gateway — all Foundry projects show green "enabled" tag. Token Management tab is visible.

[NARRATION]
In the Foundry portal, we navigate to Operate, Admin, and select AI Gateway.

Here we can create a new gateway or connect an existing one. We'll select our Foundry account and link an existing API Management instance.

All projects now show a green "enabled" tag—the gateway is connected and ready. The Token Management tab provides centralized control over token limits for each project.
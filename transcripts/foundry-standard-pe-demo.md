# About

This is transcript for Foundry demo.

## Scenario

Foundry Standard with APIM Standard v2 accessed via Private Endpoint.

Models are hosted in Azure OpenAI Service in westus region.

## Notes

- Use the name "Foundry" instead of "Azure AI Foundry".
- Foundry uses "account" and "project" terminology.
- APIM Basic v2 does not support autoscaling (manual scaling up to 10 units only).
- Foundry APIM Connection is described [here](https://github.com/microsoft-foundry/foundry-samples/blob/main/infrastructure/infrastructure-setup-bicep/01-connections/apim-and-modelgateway-integration-guide.md)
- Goal is to allow "Foundry Agent Service" to use models from APIM.
- Only the `Transcript` section is going to be read in the video.

### Instructions

- Leave [Notes] as is.
- Add [Narration] - transcript for the LLM.

## Transcript

### Part 1 - Deployment

[NARRATION]
In this demo, I'm using Azure Developer CLI to deploy API Management integrated with Foundry.

First, we're setting up networking—a virtual network with subnets for API Management, private endpoints, and Foundry's Agent Service.

Next, Foundry dependencies: Azure Storage, Cosmos DB, and AI Search—all secured with private endpoints.

Then comes API Management Standard v2 with a private endpoint, deployed into its own subnet and configured as an AI Gateway. It uses Entra ID to authenticate with Azure OpenAI—no API keys needed.

The Foundry account comes next, followed by projects. Each project gets a managed identity and capability host, which enables the Agent Service to run AI agents.

Here's the key part—the APIM Connection. We automatically link each Foundry project to API Management, giving the Agent Service access to models through the AI Gateway.

Let's let the deployment run. Once it completes, I'll show you the networking configuration and how agents call models through APIM connections - both dynamic and static.

### Part 2 - APIM Networking

[NARRATION]
Here's our API Management instance. Let's verify its networking settings.

First, the private endpoint—this handles inbound traffic. Foundry's Agent Service calls the gateway through this endpoint, keeping traffic within the virtual network.

Next, VNET integration for outbound traffic—allowing API Management to securely reach Azure OpenAI backends. No public internet exposure for enterprise compliance.

# Part 3 - Foundry Connections

[NARRATION]
Now in the Foundry portal, under Operate, you can see the project's connected resources.

We have two APIM connections configured during deployment. The dynamic connection discovers available models from the gateway automatically. The static connection has a fixed model list—useful for allowing specific deployments.

# Part 4 - Testing Agents

[NARRATION]
Now let's test with a Jupyter notebook that runs AI agents.

The notebook creates agents using both connections—dynamic and static—and sends prompts to different models through API Management.

Each request flows through the private endpoint to APIM, then to Azure OpenAI backends.

At the end, we get a summary confirming all requests completed successfully—validating our end-to-end private connectivity.
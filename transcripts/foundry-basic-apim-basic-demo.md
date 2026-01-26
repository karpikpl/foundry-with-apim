# About

This is transcript for Foundry demo.

## Scenario

Foundry Basic (no VNET) with APIM v2 Basic.

Models are hosted in Azure OpenAI Service in westus.

## Demo Flow

- 0:00 - 1:17 Azure Developer CLI deployment of fully automated infrastructure.

## Notes

- Use the name "Foundry" instead of "Azure AI Foundry".
- Foundry uses "account" and "project" terminology.
- APIM Basic v2 does not support autoscaling (manual scaling up to 10 units only).
- Foundry APIM Connection is described [here](https://github.com/microsoft-foundry/foundry-samples/blob/main/infrastructure/infrastructure-setup-bicep/01-connections/apim-and-modelgateway-integration-guide.md)
- Goal is to allow "Foundry Agent Service" to use models from APIM.
- Only the `Transcript` section is going to be read in the video.

## Transcript

### Part 1 - Deployment

[NARRATION]
In this demo, I'm deploying the core infrastructure required to integrate Azure API Management with Foundry using the new APIM Connection capability.

I'm starting by provisioning an API Management instance using the Basic v2 sku. This gives me a modern, high‑performance gateway with native support for model‑inference workloads.

This APIM instance is also pre-configured to connect to Azure OpenAI through Entra ID authentication.

Next, I'm deploying a Foundry account and projects. Projects will host my agents in the Foundry Agent Service. As part of the deployment, I'm enabling the APIM Connection, which automatically links each Foundry project to my API Management instance using a dedicated subscription key.

With this integration, the Foundry Agent Service can securely call models exposed through the AI Gateway—no manual configuration, no custom glue code, and no networking setup required.

In API Management I can set token limits, retries, load balancing and other AI Gateway features for each of my Foundry projects.

For now, let's let the deployment run. Once it completes, I'll walk through how the APIM Connection works under the hood and show how the Agent Service consumes models running on external Azure OpenAI endpoints.

### Part 2 - Workbook - Sending traffic using AI Agents

[NARRATION]
This notebook validates our AI Gateway by generating random traffic across multiple Foundry projects and models.

In the first cell, we load our Azure configuration and discover all projects in our Foundry account. For each project, we create an authenticated client using Entra Authentication.

Once projects are discovered, we can create AI Project Clients that will be used to create Agents and call the Responses API.

Next we generate random traffic. Each project gets 3 to 10 requests with random deployments and prompts. For each request, we create an agent, send a message through the gateway, and log the result.

Remember, Foundry is deployed without any models. Hence, the deployments are referenced using connection name and model name, which tells Foundry to utilize API Management connection.

We're using two different connections for each project, one with a static model list and another with dynamic model discovery.

Watch as requests flow - green checkmarks for success, red X's for failures.

This confirms Agents are able to connect to API Management for inferencing, which routes traffic to external Azure OpenAI endpoints.

### Part 3 - Dashboard with token usage

[NARRATION]
Here's our Azure Portal dashboard that aggregates all the traffic we just generated. At the top, you'll see today's and this month's token consumption at a glance.

The main chart shows token usage over time, broken down by subscription - each subscription represents a Foundry project.

Below that, we have model-level analytics showing which deployments are consuming the most tokens - gpt-4.1-mini, gpt-5-mini, o3-mini - along with their prompt versus completion token breakdown.

This dashboard pulls from API Management logs, giving us full visibility into cross-project AI consumption for chargeback and capacity planning.

### Part 4 - Foundry Portal

[NARRATION]
Now let's switch to the Foundry portal to see how this looks from the project perspective.

Here in the Agents section, you can see the agent we created during our traffic generation. 

Let's navigate to Operate. Under Connected Resources, you'll find the APIM Connection we configured during deployment. This connection links the project to our API Management instance, giving the Agent Service access to all the models exposed through the AI Gateway.

This is where you can manage and monitor the connection at the project level.

### Wrap-up

[NARRATION]
That's the complete integration - from automated deployment, to agents calling models through API Management, to centralized monitoring. With the APIM Connection, you get enterprise governance over your AI workloads without any manual wiring. Check out the repo for the full infrastructure code.
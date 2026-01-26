# About

This is transcript for Foundry demo with LiteLLM.

## Scenario

Foundry Standard with LiteLLM running in Azure Container Apps accessed via Private Endpoint.

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

### Part 1 - What was deployed

[Notes]
Length: 30s
Video shows completed deployment screen.
Next resource group view with deployed resources.
At 14 sec mark - Container App Environment hosting LiteLLM is displayed with it's networking settings blocking Public Network Access.

[NARRATION]
The deployment has completed successfully. Let's explore what was provisioned in the resource group.

Here you can see Foundry account and projects, along with supporting infrastructure including networking and monitoring resources.

Notice the Container App Environment hosting LiteLLM—its networking settings block all public access, ensuring traffic flows only through private endpoints.

### Part 2 - Model Deployment Policy

[Notes]
Length: 19s
Video shows Foundry portal with Models view.
User is attempting to deploy the o4-mini model which results in policy error - "Request Disallowed By Policy", ensuring that models are consumed via model gateway connection.

[NARRATION]
In the Foundry portal, let's try deploying a model directly.

When attempting to deploy o4-mini, we get a policy error—"Request Disallowed By Policy." This is intentional. The policy ensures all models are consumed through the LiteLLM gateway connection, not deployed directly.

# Part 3 - Lite LLM

[Notes]
Length: 30s
- [6s] Video shows LiteLLM portal with configured models.
- [7s] We're testing LiteLLM connection to gpt-4.1-mini model via Private Endpoint. Test is sucessful.
- Next user moves to playground where model is tested using chat interface (hi message)
- at the end of the movie (26-308s) we show Logs view with recent LLM calls.

[NARRATION]
Now let's look at the LiteLLM portal. Here you can see all the configured models available through the gateway.

We'll test the connection to gpt-4.1-mini via the private endpoint—and the test succeeds.

In the playground, we can interact with the model directly through a chat interface, sending a quick hello message.

Finally, the logs view shows all recent LLM calls, providing full observability into model usage.

# Part 4 - Testing Agents

[Notes]
Length: 32s

Now let's test with a Jupyter notebook that runs AI agents.

The notebook creates agents using both connections—dynamic and static—and sends prompts to different models through LiteLLM.

Each request flows through the private endpoint to proxy, then to Azure OpenAI backends.

As the reqests are processed we see them in LiteLLM (notebook and LiteLL are opened side by side)

[NARRATION]
Now let's test with a Jupyter notebook that runs AI agents.

The notebook creates agents using both connections—dynamic and static—and sends prompts to different models through LiteLLM.

Each request flows through the private endpoint to the proxy, then to Azure OpenAI backends.

With the notebook and LiteLLM side by side, you can see the requests appear in real-time as the agents process them.

# Part 5 - Log Details

[Notes]
Length: 21s

We view details of one of the requests. We see LLM request, LLM response and token usage.
Might be useful for troubleshooting and audit.

[NARRATION]
Let's drill into the details of one request.

Here we can see the full LLM request payload, the response from the model, and detailed token usage metrics.

This level of detail is invaluable for troubleshooting issues and maintaining audit trails.

# Part 6 - Test results

[Notes]
Length: 13s (but I can make it shorter for better flow)

Results - 92% completed sucesfully, one request failed due to Api Version.

[NARRATION]
Looking at the results—92% of requests completed successfully. One request failed due to an API version mismatch, which is easy to identify and fix.

# Part 7 - Usage view

[Notes]
Length: 19s

Looking at LiteLLM usage report, number of requests per model, total tokens and estimated cost

[NARRATION]
Finally, the usage report provides a complete overview—number of requests per model, total tokens consumed, and estimated cost.

This gives you full visibility into your AI usage across all models and helps manage costs effectively.
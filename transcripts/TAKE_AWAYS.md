# Foundry with APIM Takeaways

## Foundry with APIM - AI Gateway Connection

- Driven by UI - for users who don't want to manage APIM
- Doesn't support private networking (Currently)
- Main features - token limits, external agents
- Automatic tool governance - tool policies

## Foundry with APIM - apim connection

- For power users, enterprises with existign APIM / AI Gateway
- Enable to connect to any model anywhere
- All features of AI gateway supported (AI Gateway repo)
- Currently no support for Bing Grounding/Web Search - MCP solution may be available soon
- Use `ApiManagementGatewayLlmLog` for tracking usage
- Use Azure Policy to block model deployments


## Call to action

- Customers should try Agent Service ! - AI Gateway unblocks enterprises that require strict model governance and private networking
- Use with customers that chose 3rd party gateways
- Raise UATs for featutes that Foundry doesn't support yet
- Use Viva Engage to ask (and answer!) questions - support the community

<div align="center">

# 🌐 AI Gateway Deployment Options for Azure AI Foundry

<img src="./meterials/azure-ai-foundry-logo.svg" alt="Microsoft Foundry" width="200"/>

### 🚀 Bicep Templates for AI Gateway Integration with Azure AI Foundry

[![Bicep](https://img.shields.io/badge/Bicep-✓-blue.svg)](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
[![Azure](https://img.shields.io/badge/Azure-Foundry-0089D6.svg)](https://azure.microsoft.com/en-us/products/ai-foundry/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

📦 **7 Gateway Options** | 🔐 **Private Networking** | ⚡ **APIM & LiteLLM** | 🏗️ **Enterprise Ready**

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [AI Gateway Options](#-ai-gateway-options)
  - [Options Comparison](#-options-comparison)
  - [Detailed Options](#-detailed-options)
- [Quick Start](#-quick-start)
- [Prerequisites](#-prerequisites)
- [Troubleshooting](#-troubleshooting)

---

## 🌟 Overview

This repository provides **Bicep templates** for deploying **AI Gateway** patterns with Azure AI Foundry. These templates enable:

✅ **Azure API Management (APIM)** as AI Gateway for model access  
✅ **LiteLLM** as alternative model gateway with cost tracking  
✅ **OpenRouter** integration for external model providers  
✅ **Private networking** with VNet injection and private endpoints  
✅ **Multiple APIM SKUs** (Basic v2, Standard v2, Premium v2)  
✅ **Rate limiting, policies, and load balancing** capabilities  

> **Note:** AI Gateway (APIM) integration with Azure AI Foundry is expected to enter **public preview on February 13, 2026**.

---

## 🌐 AI Gateway Options

### 📊 Options Comparison

| Option | Gateway Type | Network Mode | APIM SKU | Foundry Mode | Use Case |
|--------|--------------|--------------|----------|--------------|----------|
| [**ai-gateway**](./infra/ai-gateway/) | APIM | External (Public) | Basic v2 | Standard | Quick start with VNet integration |
| [**ai-gateway-basic**](./infra/ai-gateway-basic/) | APIM | External (Public) | Basic v2 | Basic | Minimal config, no VNet required |
| [**ai-gateway-internal**](./infra/ai-gateway-internal/) | APIM | Internal (VNet) | Classic Developer | Standard | Fully private, VNet injected |
| [**ai-gateway-pe**](./infra/ai-gateway-pe/) | APIM | Private Endpoint | Standard v2 | Standard | Private endpoint to backends |
| [**ai-gateway-premium**](./infra/ai-gateway-premium/) | APIM | VNet Injection | Premium v2 | Standard | Enterprise-grade, dedicated VNet |
| [**ai-gateway-litellm**](./infra/ai-gateway-litellm/) | LiteLLM | Private + AppGW | N/A | Standard | Cost tracking, multi-model routing |
| [**ai-gateway-openrouter**](./infra/ai-gateway-openrouter/) | OpenRouter | Public | N/A | Basic (Public) | External model providers |

---

### 📁 Detailed Options

#### 🚀 [ai-gateway](./infra/ai-gateway/)

**External APIM with Foundry Standard**

Azure API Management Basic v2 in external mode acting as AI Gateway for Foundry with full VNet integration.

| Feature | Value |
|---------|-------|
| **APIM SKU** | Basic v2 |
| **Network** | External (Public IP) |
| **Foundry Mode** | Standard with Capability Hosts |
| **Agent Subnet** | ✅ Yes |
| **Private Endpoints** | Storage, Cosmos DB, AI Search |

---

#### 🎯 [ai-gateway-basic](./infra/ai-gateway-basic/)

**External APIM with Foundry Basic**

Minimal configuration for quick start - no VNet integration or capability hosts.

| Feature | Value |
|---------|-------|
| **APIM SKU** | Basic v2 |
| **Network** | External (Public IP) |
| **Foundry Mode** | Basic (no VNet) |
| **Agent Subnet** | ❌ No |
| **Private Endpoints** | None |

---

#### 🔒 [ai-gateway-internal](./infra/ai-gateway-internal/)

**Internal VNet-Injected APIM**

Fully private deployment with APIM injected into VNet and private endpoints to Azure OpenAI.

| Feature | Value |
|---------|-------|
| **APIM SKU** | Classic (VNet Injection) |
| **Network** | Internal (VNet only) |
| **Foundry Mode** | Standard with Capability Hosts |
| **Agent Subnet** | ✅ Yes |
| **Private Endpoints** | All services including OpenAI |

---

#### 🔐 [ai-gateway-pe](./infra/ai-gateway-pe/)

**APIM Standard v2 with Private Endpoint**

APIM accessible via private endpoint for backend connectivity.

| Feature | Value |
|---------|-------|
| **APIM SKU** | Standard v2 |
| **Network** | Private Endpoint |
| **Foundry Mode** | Standard with Capability Hosts |
| **Agent Subnet** | ✅ Yes |
| **Private Endpoints** | All services including OpenAI |

---

#### 💎 [ai-gateway-premium](./infra/ai-gateway-premium/)

**APIM v2 Premium with VNet Injection**

Enterprise-grade deployment with APIM Premium in dedicated VNet peered with Foundry VNet.

| Feature | Value |
|---------|-------|
| **APIM SKU** | Premium v2 |
| **Network** | VNet Injection (Internal) |
| **Foundry Mode** | Standard with Capability Hosts |
| **Agent Subnet** | ✅ Yes |
| **VNet Peering** | ✅ Dedicated APIM VNet |
| **Private Endpoints** | All services including OpenAI |

---

#### ⚡ [ai-gateway-litellm](./infra/ai-gateway-litellm/)

**LiteLLM Gateway on Azure Container Apps**

LiteLLM as model gateway with PostgreSQL for configuration and spend tracking.

| Feature | Value |
|---------|-------|
| **Gateway** | LiteLLM (Container Apps) |
| **Database** | PostgreSQL Flexible Server |
| **Public Access** | Application Gateway |
| **Foundry Mode** | Standard with Capability Hosts |
| **Cost Tracking** | ✅ Built-in |
| **Admin UI** | ✅ Via Application Gateway |

---

#### 🌍 [ai-gateway-openrouter](./infra/ai-gateway-openrouter/)

**OpenRouter as External Model Gateway**

Public Foundry connecting to OpenRouter for access to multiple AI providers.

| Feature | Value |
|---------|-------|
| **Gateway** | OpenRouter API |
| **Network** | Public Internet |
| **Foundry Mode** | Basic (Public) |
| **Agent Subnet** | ❌ No |
| **Authentication** | API Key |
| **Model Access** | Multiple providers (OpenAI, Anthropic, etc.) |

---

## 🚀 Quick Start

### 1️⃣ Clone and Navigate

```bash
git clone https://github.com/your-org/foundry-with-apim.git
cd foundry-with-apim/infra/<deployment-option>
```

### 2️⃣ Point at your existing Foundry / Azure OpenAI resource(s)

The APIM-based options (`ai-gateway`, `ai-gateway-basic`, `ai-gateway-internal`, `ai-gateway-pe`, `ai-gateway-premium`) **bring your own** Foundry/Azure OpenAI account(s). A preprovision hook ([`infra/scripts/preprovision-list-foundry-models.sh`](./infra/scripts/preprovision-list-foundry-models.sh) / `.ps1`) enumerates the model deployments on those accounts via ARM and writes them into `FOUNDRY_INSTANCES_JSON`, which `main.bicepparam` consumes to synthesise per-model APIM backends and pools.

```bash
# Preferred: one or more Foundry / Azure OpenAI accounts (comma-separated)
export EXISTING_FOUNDRY_RESOURCE_IDS="/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.CognitiveServices/accounts/<foundry-1>,/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.CognitiveServices/accounts/<foundry-2>"

# Backwards-compatible single-instance fallbacks also accepted:
#   EXISTING_FOUNDRY_RESOURCE_ID   or   OPENAI_RESOURCE_ID

# Optional: front another APIM gateway that already exposes a per-model catalog
# export EXISTING_APIM_RESOURCE_IDS="/subscriptions/.../Microsoft.ApiManagement/service/<apim>"

# For the LiteLLM option
export OPENAI_API_KEY="your-azure-openai-api-key"

# For the OpenRouter option
export OPENROUTER_API_KEY="your-openrouter-api-key"
```

Model deployments are **auto-discovered** — you don't list them. If no inputs are set the script writes `[]` and the Bicep deployment fails fast with a clear error.

### 3️⃣ Deploy

```bash
azd up
```

---

## 📋 Prerequisites

- ✅ **Azure CLI** and **Azure Developer CLI (azd)** installed
- ✅ **Azure subscription** with AI services quota
- ✅ **Required roles**: Owner or Contributor + User Access Administrator
- ✅ **Existing Foundry / Azure OpenAI account(s)** with model deployments (for APIM-based options — the preprovision hook needs `Cognitive Services Usages Reader` or equivalent to list deployments)

#### 📦 Register Resource Providers

```bash
az provider register --namespace 'Microsoft.CognitiveServices'
az provider register --namespace 'Microsoft.ApiManagement'
az provider register --namespace 'Microsoft.Storage'
az provider register --namespace 'Microsoft.Search'
az provider register --namespace 'Microsoft.DocumentDB'
az provider register --namespace 'Microsoft.Network'
az provider register --namespace 'Microsoft.App'
az provider register --namespace 'Microsoft.ContainerService'
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| ❌ **APIM deployment slow** | APIM v2 Premium can take 30-45 minutes to deploy |
| ❌ **Private endpoint connectivity** | Verify DNS zones are linked to VNet |
| ❌ **Model not accessible** | Check APIM managed identity has Cognitive Services User role |
| ❌ **Agent Service errors** | Ensure Capability Host is configured correctly |
| ❌ **VNet injection fails** | Verify subnet is properly sized and delegated |

---

## 📚 Additional Resources

- 📖 **[Microsoft Foundry Documentation](https://learn.microsoft.com/azure/ai-foundry/)**
- 🤖 **[Foundry Samples - by Product Team](https://aka.ms/foundrySamples)
- 📍 **[More Foundry deployment scenarios](https://github.com/msft-mfg-ai/ai-foundry-deployment-options)
- 🌐 **[AI Gateway Labs](https://azure-samples.github.io/AI-Gateway/)**
- 🔧 **[Azure API Management](https://learn.microsoft.com/azure/api-management/)**
- ⚡ **[LiteLLM Documentation](https://docs.litellm.ai/)**
- 🌍 **[OpenRouter API](https://openrouter.ai/docs)**
- 🏢 **[AI Hub Gateway Landing Zone](aka.ms/ai-hub-gateway)**
- 🛬 **[AI Landing Zone](aka.ms/ai-hub-gateway)**

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ for Azure AI**

</div>

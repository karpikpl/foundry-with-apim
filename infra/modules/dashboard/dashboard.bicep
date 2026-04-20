// Azure Portal Dashboard for APIM Token Usage Monitoring
// Based on AI-Gateway FinOps Framework patterns
// Uses ApiManagementGatewayLlmLog for accurate token data (actual counts, even for streaming)
// Joins with ApiManagementGatewayLogs to get caller name from x-caller-name header

@description('Location for the dashboard')
param location string

@description('Dashboard display name')
param dashboardDisplayName string

@description('Log Analytics Workspace resource ID for gateway logs')
param logAnalyticsWorkspaceId string

// ------------------
//    VARIABLES
// ------------------

var dashboardName = 'apim-token-dashboard-${toLower(uniqueString(resourceGroup().id, location))}'

// KQL Queries for dashboard tiles
// All queries use ApiManagementGatewayLlmLog (actual token counts, even for streaming)
// Caller identity comes from x-caller-name header in ApiManagementGatewayLogs.BackendRequestHeaders

var kqlTodayStats = '''
ApiManagementGatewayLlmLog
| where isnotempty(DeploymentName)
| where TimeGenerated >= startofday(now())
| summarize
    TodayPromptTokens = sum(PromptTokens),
    TodayCompletionTokens = sum(CompletionTokens),
    TodayTotalTokens = sum(TotalTokens),
    TodayRequests = dcount(CorrelationId)
'''

var kqlMonthStats = '''
let llmLogs = ApiManagementGatewayLlmLog
| where isnotempty(DeploymentName)
| where TimeGenerated >= startofmonth(now());
let callers = ApiManagementGatewayLogs
| where TimeGenerated >= startofmonth(now())
| where BackendRequestHeaders has "x-caller-name"
| extend CallerName = extract(@'"x-caller-name":"([^"]+)"', 1, tostring(BackendRequestHeaders))
| summarize CallerName = any(CallerName) by CorrelationId;
llmLogs
| join kind=leftouter callers on CorrelationId
| summarize
    MonthTotalTokens = sum(TotalTokens),
    MonthRequests = dcount(CorrelationId),
    UniqueCallers = dcount(CallerName)
'''

var kqlTokenUsageOverTime = '''
let llmLogs = ApiManagementGatewayLlmLog
| where isnotempty(DeploymentName)
| project TimeGenerated, TotalTokens, CorrelationId;
let callers = ApiManagementGatewayLogs
| where BackendRequestHeaders has "x-caller-name"
| extend CallerName = extract(@'"x-caller-name":"([^"]+)"', 1, tostring(BackendRequestHeaders))
| summarize CallerName = any(CallerName) by CorrelationId;
llmLogs
| join kind=leftouter callers on CorrelationId
| extend CallerName = coalesce(CallerName, "Unknown")
| summarize TotalTokens = sum(TotalTokens) by bin(TimeGenerated, 1h), CallerName
| order by TimeGenerated asc
'''

var kqlTopConsumers = '''
let llmLogs = ApiManagementGatewayLlmLog
| where isnotempty(DeploymentName)
| where TimeGenerated >= ago(30d);
let callers = ApiManagementGatewayLogs
| where TimeGenerated >= ago(30d)
| where BackendRequestHeaders has "x-caller-name"
| extend CallerName = extract(@'"x-caller-name":"([^"]+)"', 1, tostring(BackendRequestHeaders))
| summarize CallerName = any(CallerName) by CorrelationId;
let totalTokens = toscalar(llmLogs | summarize sum(TotalTokens));
llmLogs
| join kind=leftouter callers on CorrelationId
| extend CallerName = coalesce(CallerName, "Unknown")
| summarize TotalTokens = sum(TotalTokens), Requests = dcount(CorrelationId) by CallerName
| top 10 by TotalTokens desc
| extend Percentage = round(TotalTokens * 100.0 / totalTokens, 1)
'''

var kqlDailyUsageSummary = '''
let llmLogs = ApiManagementGatewayLlmLog
| where isnotempty(DeploymentName)
| project TimeGenerated, PromptTokens, CompletionTokens, TotalTokens, CorrelationId;
let callers = ApiManagementGatewayLogs
| where BackendRequestHeaders has "x-caller-name"
| extend CallerName = extract(@'"x-caller-name":"([^"]+)"', 1, tostring(BackendRequestHeaders))
| summarize CallerName = any(CallerName) by CorrelationId;
llmLogs
| join kind=leftouter callers on CorrelationId
| extend CallerName = coalesce(CallerName, "Unknown")
| summarize
    PromptTokens = sum(PromptTokens),
    CompletionTokens = sum(CompletionTokens),
    TotalTokens = sum(TotalTokens),
    Requests = dcount(CorrelationId)
by bin(TimeGenerated, 1d), CallerName
| order by TimeGenerated desc
'''

var kqlModelUsage = '''
ApiManagementGatewayLlmLog
| where isnotempty(DeploymentName)
| summarize
    PromptTokens = sum(PromptTokens),
    CompletionTokens = sum(CompletionTokens),
    TotalTokens = sum(TotalTokens),
    Requests = dcount(CorrelationId)
by DeploymentName, ModelName
| order by TotalTokens desc
'''

var kqlModelUsageByProject = '''
let llmLogs = ApiManagementGatewayLlmLog
| where isnotempty(DeploymentName)
| project TimeGenerated, DeploymentName, ModelName, PromptTokens, CompletionTokens, TotalTokens, CorrelationId;
let callers = ApiManagementGatewayLogs
| where BackendRequestHeaders has "x-caller-name"
| extend CallerName = extract(@'"x-caller-name":"([^"]+)"', 1, tostring(BackendRequestHeaders))
| summarize CallerName = any(CallerName) by CorrelationId;
llmLogs
| join kind=leftouter callers on CorrelationId
| extend CallerName = coalesce(CallerName, "Unknown")
| summarize
    PromptTokens = sum(PromptTokens),
    CompletionTokens = sum(CompletionTokens),
    TotalTokens = sum(TotalTokens),
    Requests = dcount(CorrelationId)
by CallerName, DeploymentName
| order by CallerName, TotalTokens desc
'''

var kqlTotalTokensPerProject = '''
let llmLogs = ApiManagementGatewayLlmLog
| where isnotempty(DeploymentName)
| project PromptTokens, CompletionTokens, TotalTokens, CorrelationId;
let callers = ApiManagementGatewayLogs
| where BackendRequestHeaders has "x-caller-name"
| extend CallerName = extract(@'"x-caller-name":"([^"]+)"', 1, tostring(BackendRequestHeaders))
| summarize CallerName = any(CallerName) by CorrelationId;
llmLogs
| join kind=leftouter callers on CorrelationId
| extend CallerName = coalesce(CallerName, "Unknown")
| summarize
    PromptTokens = sum(PromptTokens),
    CompletionTokens = sum(CompletionTokens),
    TotalTokens = sum(TotalTokens),
    Requests = dcount(CorrelationId)
by CallerName
| order by TotalTokens desc
'''

// ------------------
//    RESOURCES
// ------------------

resource dashboard 'Microsoft.Portal/dashboards@2022-12-01-preview' = {
  name: dashboardName
  location: location
  tags: {
    'hidden-title': dashboardDisplayName
  }
  properties: {
    lenses: [
      {
        order: 0
        parts: [
          // Title/Header - Row 0-1, full width
          {
            position: {
              x: 0
              y: 0
              colSpan: 12
              rowSpan: 2
            }
            metadata: {
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              inputs: []
              settings: {
                content: {
                  content: '# 🤖 APIM Token Usage Dashboard\n\nMonitor LLM token consumption by caller. Data sourced from `ApiManagementGatewayLlmLog` (actual token counts, even for streaming) joined with `ApiManagementGatewayLogs` (caller identity via x-caller-name header).'
                  title: 'APIM Token Usage Dashboard'
                  subtitle: ''
                  markdownSource: 1
                }
              }
            }
          }
          // Today's Stats - Row 2-3, left half
          {
            position: {
              x: 0
              y: 2
              colSpan: 6
              rowSpan: 2
            }
            metadata: {
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              inputs: [
                { name: 'resourceTypeMode', isOptional: true }
                { name: 'ComponentId', isOptional: true }
                { name: 'Scope', value: { resourceIds: [ logAnalyticsWorkspaceId ] }, isOptional: true }
                { name: 'Version', value: '2.0', isOptional: true }
                { name: 'TimeRange', value: 'P1D', isOptional: true }
                { name: 'DashboardId', isOptional: true }
                { name: 'PartId', value: 'today-stats', isOptional: true }
                { name: 'PartTitle', value: '📊 Today\'s Usage', isOptional: true }
                { name: 'PartSubTitle', value: 'ApiManagementGatewayLlmLog', isOptional: true }
                { name: 'Query', value: kqlTodayStats, isOptional: true }
                { name: 'ControlType', value: 'AnalyticsGrid', isOptional: true }
                { name: 'DraftRequestParameters', isOptional: true }
                { name: 'SpecificChart', isOptional: true }
                { name: 'Dimensions', isOptional: true }
                { name: 'LegendOptions', isOptional: true }
                { name: 'IsQueryContainTimeRange', isOptional: true }
              ]
              settings: {}
            }
          }
          // Month Stats - Row 2-3, right half
          {
            position: {
              x: 6
              y: 2
              colSpan: 6
              rowSpan: 2
            }
            metadata: {
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              inputs: [
                { name: 'Scope', value: { resourceIds: [ logAnalyticsWorkspaceId ] }, isOptional: true }
                { name: 'Version', value: '2.0', isOptional: true }
                { name: 'TimeRange', value: 'P30D', isOptional: true }
                { name: 'PartId', value: 'month-stats', isOptional: true }
                { name: 'PartTitle', value: '📅 This Month', isOptional: true }
                { name: 'PartSubTitle', value: 'ApiManagementGatewayLlmLog', isOptional: true }
                { name: 'Query', value: kqlMonthStats, isOptional: true }
                { name: 'ControlType', value: 'AnalyticsGrid', isOptional: true }
                { name: 'resourceTypeMode', isOptional: true }
                { name: 'ComponentId', isOptional: true }
                { name: 'DashboardId', isOptional: true }
                { name: 'DraftRequestParameters', isOptional: true }
                { name: 'SpecificChart', isOptional: true }
                { name: 'Dimensions', isOptional: true }
                { name: 'LegendOptions', isOptional: true }
                { name: 'IsQueryContainTimeRange', isOptional: true }
              ]
              settings: {}
            }
          }
          // Token Usage Over Time Chart - Row 4-8, wide (17 cols for chart)
          {
            position: {
              x: 0
              y: 4
              colSpan: 17
              rowSpan: 5
            }
            metadata: {
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              inputs: [
                { name: 'Scope', value: { resourceIds: [ logAnalyticsWorkspaceId ] }, isOptional: true }
                { name: 'Version', value: '2.0', isOptional: true }
                { name: 'TimeRange', value: 'P7D', isOptional: true }
                { name: 'PartId', value: 'usage-over-time', isOptional: true }
                { name: 'PartTitle', value: '📈 Token Usage Over Time by Project', isOptional: true }
                { name: 'PartSubTitle', value: 'Hourly token consumption by project/subscription', isOptional: true }
                { name: 'Query', value: kqlTokenUsageOverTime, isOptional: true }
                { name: 'ControlType', value: 'AnalyticsGrid', isOptional: true }
                { name: 'resourceTypeMode', isOptional: true }
                { name: 'ComponentId', isOptional: true }
                { name: 'DashboardId', isOptional: true }
                { name: 'DraftRequestParameters', isOptional: true }
                { name: 'SpecificChart', isOptional: true }
                { name: 'Dimensions', isOptional: true }
                { name: 'LegendOptions', isOptional: true }
                { name: 'IsQueryContainTimeRange', isOptional: true }
              ]
              settings: {
                content: {
                  Query: '${kqlTokenUsageOverTime}\n'
                  ControlType: 'FrameControlChart'
                  SpecificChart: 'StackedColumn'
                  Dimensions: {
                    xAxis: { name: 'TimeGenerated', type: 'datetime' }
                    yAxis: [ { name: 'TotalTokens', type: 'long' } ]
                    splitBy: [ { name: 'CallerName', type: 'string' } ]
                    aggregation: 'Sum'
                  }
                  LegendOptions: { isEnabled: true, position: 'Bottom' }
                }
              }
            }
          }
          // Top Consumers - Row 10-12, left
          {
            position: {
              x: 0
              y: 10
              colSpan: 8
              rowSpan: 3
            }
            metadata: {
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              inputs: [
                { name: 'Scope', value: { resourceIds: [ logAnalyticsWorkspaceId ] }, isOptional: true }
                { name: 'Version', value: '2.0', isOptional: true }
                { name: 'TimeRange', value: 'P30D', isOptional: true }
                { name: 'PartId', value: 'top-consumers', isOptional: true }
                { name: 'PartTitle', value: '🏆 Top Token Consumers by Project', isOptional: true }
                { name: 'PartSubTitle', value: 'Last 30 days', isOptional: true }
                { name: 'Query', value: kqlTopConsumers, isOptional: true }
                { name: 'ControlType', value: 'AnalyticsGrid', isOptional: true }
                { name: 'resourceTypeMode', isOptional: true }
                { name: 'ComponentId', isOptional: true }
                { name: 'DashboardId', isOptional: true }
                { name: 'DraftRequestParameters', isOptional: true }
                { name: 'SpecificChart', isOptional: true }
                { name: 'Dimensions', isOptional: true }
                { name: 'LegendOptions', isOptional: true }
                { name: 'IsQueryContainTimeRange', isOptional: true }
              ]
              settings: {}
            }
          }
          // Daily Summary - Row 10-12, right
          {
            position: {
              x: 8
              y: 10
              colSpan: 9
              rowSpan: 3
            }
            metadata: {
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              inputs: [
                { name: 'Scope', value: { resourceIds: [ logAnalyticsWorkspaceId ] }, isOptional: true }
                { name: 'Version', value: '2.0', isOptional: true }
                { name: 'TimeRange', value: 'P30D', isOptional: true }
                { name: 'PartId', value: 'daily-summary', isOptional: true }
                { name: 'PartTitle', value: '📊 Daily Usage by Project', isOptional: true }
                { name: 'PartSubTitle', value: 'Prompt, Completion, and Total tokens per day by project', isOptional: true }
                { name: 'Query', value: kqlDailyUsageSummary, isOptional: true }
                { name: 'ControlType', value: 'AnalyticsGrid', isOptional: true }
                { name: 'resourceTypeMode', isOptional: true }
                { name: 'ComponentId', isOptional: true }
                { name: 'DashboardId', isOptional: true }
                { name: 'DraftRequestParameters', isOptional: true }
                { name: 'SpecificChart', isOptional: true }
                { name: 'Dimensions', isOptional: true }
                { name: 'LegendOptions', isOptional: true }
                { name: 'IsQueryContainTimeRange', isOptional: true }
              ]
              settings: {}
            }
          }
          // Usage by Model - Row 13-15, full width
          {
            position: {
              x: 0
              y: 13
              colSpan: 12
              rowSpan: 3
            }
            metadata: {
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              inputs: [
                { name: 'Scope', value: { resourceIds: [ logAnalyticsWorkspaceId ] }, isOptional: true }
                { name: 'Version', value: '2.0', isOptional: true }
                { name: 'TimeRange', value: 'P30D', isOptional: true }
                { name: 'PartId', value: 'model-usage', isOptional: true }
                { name: 'PartTitle', value: '🧠 Usage by Model', isOptional: true }
                { name: 'PartSubTitle', value: 'Token consumption per deployment', isOptional: true }
                { name: 'Query', value: kqlModelUsage, isOptional: true }
                { name: 'ControlType', value: 'AnalyticsGrid', isOptional: true }
                { name: 'resourceTypeMode', isOptional: true }
                { name: 'ComponentId', isOptional: true }
                { name: 'DashboardId', isOptional: true }
                { name: 'DraftRequestParameters', isOptional: true }
                { name: 'SpecificChart', isOptional: true }
                { name: 'Dimensions', isOptional: true }
                { name: 'LegendOptions', isOptional: true }
                { name: 'IsQueryContainTimeRange', isOptional: true }
              ]
              settings: {}
            }
          }
          // Model Usage by Project - Row 16-19, full width - answers "what models is each project using?"
          {
            position: {
              x: 0
              y: 16
              colSpan: 12
              rowSpan: 4
            }
            metadata: {
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              inputs: [
                { name: 'Scope', value: { resourceIds: [ logAnalyticsWorkspaceId ] }, isOptional: true }
                { name: 'Version', value: '2.0', isOptional: true }
                { name: 'TimeRange', value: 'P30D', isOptional: true }
                { name: 'PartId', value: 'model-usage-by-project', isOptional: true }
                { name: 'PartTitle', value: '🔗 Models Used by Project', isOptional: true }
                { name: 'PartSubTitle', value: 'Which deployments/models each project is consuming', isOptional: true }
                { name: 'Query', value: kqlModelUsageByProject, isOptional: true }
                { name: 'ControlType', value: 'AnalyticsGrid', isOptional: true }
                { name: 'resourceTypeMode', isOptional: true }
                { name: 'ComponentId', isOptional: true }
                { name: 'DashboardId', isOptional: true }
                { name: 'DraftRequestParameters', isOptional: true }
                { name: 'SpecificChart', isOptional: true }
                { name: 'Dimensions', isOptional: true }
                { name: 'LegendOptions', isOptional: true }
                { name: 'IsQueryContainTimeRange', isOptional: true }
              ]
              settings: {}
            }
          }
          // Total Tokens per Subscription - Row 20-24, full width
          {
            position: {
              x: 0
              y: 20
              colSpan: 12
              rowSpan: 5
            }
            metadata: {
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              inputs: [
                { name: 'Scope', value: { resourceIds: [ logAnalyticsWorkspaceId ] }, isOptional: true }
                { name: 'Version', value: '2.0', isOptional: true }
                { name: 'TimeRange', value: 'P30D', isOptional: true }
                { name: 'PartId', value: 'total-tokens-project', isOptional: true }
                { name: 'PartTitle', value: '💰 Total Tokens by Project', isOptional: true }
                { name: 'PartSubTitle', value: 'All-time token usage by project', isOptional: true }
                { name: 'Query', value: kqlTotalTokensPerProject, isOptional: true }
                { name: 'ControlType', value: 'AnalyticsGrid', isOptional: true }
                { name: 'resourceTypeMode', isOptional: true }
                { name: 'ComponentId', isOptional: true }
                { name: 'DashboardId', isOptional: true }
                { name: 'DraftRequestParameters', isOptional: true }
                { name: 'SpecificChart', isOptional: true }
                { name: 'Dimensions', isOptional: true }
                { name: 'LegendOptions', isOptional: true }
                { name: 'IsQueryContainTimeRange', isOptional: true }
              ]
              settings: {}
            }
          }
        ]
      }
    ]
    metadata: {
      model: {
        timeRange: {
          value: {
            relative: {
              duration: 24
              timeUnit: 1
            }
          }
          type: 'MsPortalFx.Composition.Configuration.ValueTypes.TimeRange'
        }
        filterLocale: {
          value: 'en-us'
        }
        filters: {
          value: {
            MsPortalFx_TimeRange: {
              model: {
                format: 'utc'
                granularity: 'auto'
                relative: '7d'
              }
              displayCache: {
                name: 'UTC Time'
                value: 'Past 7 days'
              }
            }
          }
        }
      }
    }
  }
}

// ------------------
//    OUTPUTS
// ------------------

output dashboardId string = dashboard.id
output dashboardName string = dashboard.name

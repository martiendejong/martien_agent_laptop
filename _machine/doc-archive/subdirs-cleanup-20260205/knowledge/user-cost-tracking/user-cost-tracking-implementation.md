# PER-USER TOKEN COST TRACKING - IMPLEMENTATION GUIDE

**Date:** 2026-01-12
**Purpose:** Reusable component for tracking AI costs per user across Hazina-based applications
**Target Apps:** ArtRevisionist, Client-Manager, and any future Hazina apps

---

## ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────┐
│           Frontend (React/TypeScript)           │
│  ┌───────────────────────────────────────────┐  │
│  │      UserCostDashboard Component          │  │
│  │  - Total cost display                     │  │
│  │  - Cost breakdown by model/date           │  │
│  │  - Budget alerts                          │  │
│  └───────────────┬───────────────────────────┘  │
└──────────────────┼──────────────────────────────┘
                   │ HTTP GET /api/user-costs/{userId}
                   │
┌──────────────────▼──────────────────────────────┐
│              Backend API                        │
│  ┌───────────────────────────────────────────┐  │
│  │     UserTokenCostController               │  │
│  │  - GetUserTotalCost(userId)               │  │
│  │  - GetUserCostBreakdown(userId, dates)    │  │
│  │  - GetUserCostTimeline(userId, dates)     │  │
│  └───────────────┬───────────────────────────┘  │
│                  │                               │
│  ┌───────────────▼───────────────────────────┐  │
│  │     UserTokenCostService                  │  │
│  │  - Calculate cost from ILLMLogRepository  │  │
│  │  - Apply pricing rules per provider       │  │
│  │  - Cache results (5 min TTL)              │  │
│  └───────────────┬───────────────────────────┘  │
└──────────────────┼──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         Hazina.Observability.LLMLogs            │
│  ┌───────────────────────────────────────────┐  │
│  │         ILLMLogRepository                  │  │
│  │  - GetLogsAsync(userId, dateRange)        │  │
│  │  - Already exists in both apps            │  │
│  └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

---

## BACKEND IMPLEMENTATION

### 1. Data Models

```csharp
// Models/UserTokenCostModels.cs

namespace Hazina.Observability.UserCosts
{
    /// <summary>
    /// Summary of total costs for a user
    /// </summary>
    public class UserCostSummary
    {
        public string UserId { get; set; }
        public decimal TotalCost { get; set; }
        public long TotalTokens { get; set; }
        public int TotalRequests { get; set; }
        public DateTime FirstRequest { get; set; }
        public DateTime LastRequest { get; set; }
        public Dictionary<string, decimal> CostByProvider { get; set; } = new();
        public Dictionary<string, decimal> CostByModel { get; set; } = new();
    }

    /// <summary>
    /// Detailed cost breakdown with filters
    /// </summary>
    public class UserCostBreakdown
    {
        public string UserId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal TotalCost { get; set; }
        public List<CostByModel> ModelBreakdown { get; set; } = new();
        public List<CostByProvider> ProviderBreakdown { get; set; } = new();
        public List<CostByDate> DailyBreakdown { get; set; } = new();
    }

    public class CostByModel
    {
        public string Model { get; set; }
        public decimal Cost { get; set; }
        public long Tokens { get; set; }
        public int RequestCount { get; set; }
        public decimal AverageCostPerRequest { get; set; }
    }

    public class CostByProvider
    {
        public string Provider { get; set; }
        public decimal Cost { get; set; }
        public long Tokens { get; set; }
        public int RequestCount { get; set; }
    }

    public class CostByDate
    {
        public DateTime Date { get; set; }
        public decimal Cost { get; set; }
        public long Tokens { get; set; }
        public int RequestCount { get; set; }
    }

    /// <summary>
    /// Time-series data for charts
    /// </summary>
    public class UserCostTimeline
    {
        public string UserId { get; set; }
        public List<TimelineDataPoint> DataPoints { get; set; } = new();
        public decimal TotalCost { get; set; }
        public string Period { get; set; } // "hourly", "daily", "weekly"
    }

    public class TimelineDataPoint
    {
        public DateTime Timestamp { get; set; }
        public decimal Cost { get; set; }
        public long Tokens { get; set; }
        public int RequestCount { get; set; }
    }
}
```

---

### 2. Core Service

```csharp
// Services/UserTokenCostService.cs

using Hazina.Observability.LLMLogs.Storage;
using Hazina.Observability.UserCosts;
using Microsoft.Extensions.Caching.Memory;

namespace Hazina.Observability.Services
{
    public interface IUserTokenCostService
    {
        Task<UserCostSummary> GetUserTotalCostAsync(string userId);
        Task<UserCostBreakdown> GetUserCostBreakdownAsync(
            string userId,
            DateTime? startDate = null,
            DateTime? endDate = null);
        Task<UserCostTimeline> GetUserCostTimelineAsync(
            string userId,
            DateTime startDate,
            DateTime endDate,
            string period = "daily");
        Task<List<UserCostSummary>> GetTopCostUsersAsync(
            DateTime? startDate = null,
            DateTime? endDate = null,
            int limit = 10);
    }

    public class UserTokenCostService : IUserTokenCostService
    {
        private readonly ILLMLogRepository _logRepository;
        private readonly IMemoryCache _cache;
        private const int CacheDurationMinutes = 5;

        public UserTokenCostService(
            ILLMLogRepository logRepository,
            IMemoryCache cache)
        {
            _logRepository = logRepository;
            _cache = cache;
        }

        public async Task<UserCostSummary> GetUserTotalCostAsync(string userId)
        {
            var cacheKey = $"user_cost_summary_{userId}";

            if (_cache.TryGetValue(cacheKey, out UserCostSummary cached))
                return cached;

            // Get all logs for this user (no date filter = all time)
            var logs = await _logRepository.GetLogsAsync(
                startDate: DateTime.MinValue,
                endDate: DateTime.MaxValue,
                userId: userId);

            if (!logs.Any())
            {
                return new UserCostSummary
                {
                    UserId = userId,
                    TotalCost = 0,
                    TotalTokens = 0,
                    TotalRequests = 0
                };
            }

            var summary = new UserCostSummary
            {
                UserId = userId,
                TotalCost = logs.Sum(l => CalculateCost(l)),
                TotalTokens = logs.Sum(l => l.TokenUsage.TotalTokens),
                TotalRequests = logs.Count(),
                FirstRequest = logs.Min(l => l.Timestamp),
                LastRequest = logs.Max(l => l.Timestamp),
                CostByProvider = logs
                    .GroupBy(l => l.Provider)
                    .ToDictionary(
                        g => g.Key,
                        g => g.Sum(l => CalculateCost(l))),
                CostByModel = logs
                    .GroupBy(l => l.Model)
                    .ToDictionary(
                        g => g.Key,
                        g => g.Sum(l => CalculateCost(l)))
            };

            _cache.Set(cacheKey, summary, TimeSpan.FromMinutes(CacheDurationMinutes));
            return summary;
        }

        public async Task<UserCostBreakdown> GetUserCostBreakdownAsync(
            string userId,
            DateTime? startDate = null,
            DateTime? endDate = null)
        {
            var start = startDate ?? DateTime.UtcNow.AddDays(-30);
            var end = endDate ?? DateTime.UtcNow;

            var logs = await _logRepository.GetLogsAsync(start, end, userId: userId);

            var breakdown = new UserCostBreakdown
            {
                UserId = userId,
                StartDate = start,
                EndDate = end,
                TotalCost = logs.Sum(l => CalculateCost(l)),
                ModelBreakdown = logs
                    .GroupBy(l => l.Model)
                    .Select(g => new CostByModel
                    {
                        Model = g.Key,
                        Cost = g.Sum(l => CalculateCost(l)),
                        Tokens = g.Sum(l => l.TokenUsage.TotalTokens),
                        RequestCount = g.Count(),
                        AverageCostPerRequest = g.Average(l => CalculateCost(l))
                    })
                    .OrderByDescending(m => m.Cost)
                    .ToList(),
                ProviderBreakdown = logs
                    .GroupBy(l => l.Provider)
                    .Select(g => new CostByProvider
                    {
                        Provider = g.Key,
                        Cost = g.Sum(l => CalculateCost(l)),
                        Tokens = g.Sum(l => l.TokenUsage.TotalTokens),
                        RequestCount = g.Count()
                    })
                    .OrderByDescending(p => p.Cost)
                    .ToList(),
                DailyBreakdown = logs
                    .GroupBy(l => l.Timestamp.Date)
                    .Select(g => new CostByDate
                    {
                        Date = g.Key,
                        Cost = g.Sum(l => CalculateCost(l)),
                        Tokens = g.Sum(l => l.TokenUsage.TotalTokens),
                        RequestCount = g.Count()
                    })
                    .OrderBy(d => d.Date)
                    .ToList()
            };

            return breakdown;
        }

        public async Task<UserCostTimeline> GetUserCostTimelineAsync(
            string userId,
            DateTime startDate,
            DateTime endDate,
            string period = "daily")
        {
            var logs = await _logRepository.GetLogsAsync(startDate, endDate, userId: userId);

            var dataPoints = period switch
            {
                "hourly" => logs
                    .GroupBy(l => new DateTime(l.Timestamp.Year, l.Timestamp.Month, l.Timestamp.Day, l.Timestamp.Hour, 0, 0))
                    .Select(CreateDataPoint)
                    .OrderBy(d => d.Timestamp)
                    .ToList(),
                "daily" => logs
                    .GroupBy(l => l.Timestamp.Date)
                    .Select(CreateDataPoint)
                    .OrderBy(d => d.Timestamp)
                    .ToList(),
                "weekly" => logs
                    .GroupBy(l => GetWeekStart(l.Timestamp))
                    .Select(CreateDataPoint)
                    .OrderBy(d => d.Timestamp)
                    .ToList(),
                _ => throw new ArgumentException($"Invalid period: {period}")
            };

            return new UserCostTimeline
            {
                UserId = userId,
                DataPoints = dataPoints,
                TotalCost = dataPoints.Sum(d => d.Cost),
                Period = period
            };
        }

        public async Task<List<UserCostSummary>> GetTopCostUsersAsync(
            DateTime? startDate = null,
            DateTime? endDate = null,
            int limit = 10)
        {
            var start = startDate ?? DateTime.UtcNow.AddDays(-30);
            var end = endDate ?? DateTime.UtcNow;

            var logs = await _logRepository.GetLogsAsync(start, end);

            var topUsers = logs
                .GroupBy(l => l.UserId)
                .Select(g => new UserCostSummary
                {
                    UserId = g.Key,
                    TotalCost = g.Sum(l => CalculateCost(l)),
                    TotalTokens = g.Sum(l => l.TokenUsage.TotalTokens),
                    TotalRequests = g.Count(),
                    FirstRequest = g.Min(l => l.Timestamp),
                    LastRequest = g.Max(l => l.Timestamp)
                })
                .OrderByDescending(u => u.TotalCost)
                .Take(limit)
                .ToList();

            return topUsers;
        }

        // Helper methods

        private TimelineDataPoint CreateDataPoint(IGrouping<DateTime, LLMLogEntry> group)
        {
            return new TimelineDataPoint
            {
                Timestamp = group.Key,
                Cost = group.Sum(l => CalculateCost(l)),
                Tokens = group.Sum(l => l.TokenUsage.TotalTokens),
                RequestCount = group.Count()
            };
        }

        private DateTime GetWeekStart(DateTime date)
        {
            int diff = (7 + (date.DayOfWeek - DayOfWeek.Monday)) % 7;
            return date.AddDays(-1 * diff).Date;
        }

        private decimal CalculateCost(LLMLogEntry log)
        {
            // Pricing as of January 2026 (update regularly)
            return log.Provider switch
            {
                "OpenAI" => CalculateOpenAICost(log.Model, log.TokenUsage),
                "Anthropic" => CalculateAnthropicCost(log.Model, log.TokenUsage),
                "Ollama" => 0m, // Local inference = free
                "Google" => CalculateGoogleCost(log.Model, log.TokenUsage),
                _ => 0m
            };
        }

        private decimal CalculateOpenAICost(string model, TokenUsageInfo tokens)
        {
            return model switch
            {
                "gpt-4o" =>
                    (tokens.InputTokens / 1_000_000m * 2.50m) +
                    (tokens.OutputTokens / 1_000_000m * 10.00m),
                "gpt-4o-mini" =>
                    (tokens.InputTokens / 1_000_000m * 0.15m) +
                    (tokens.OutputTokens / 1_000_000m * 0.60m),
                "gpt-4-turbo" =>
                    (tokens.InputTokens / 1_000_000m * 10.00m) +
                    (tokens.OutputTokens / 1_000_000m * 30.00m),
                "gpt-4" =>
                    (tokens.InputTokens / 1_000_000m * 30.00m) +
                    (tokens.OutputTokens / 1_000_000m * 60.00m),
                "gpt-3.5-turbo" =>
                    (tokens.InputTokens / 1_000_000m * 0.50m) +
                    (tokens.OutputTokens / 1_000_000m * 1.50m),
                "text-embedding-3-small" =>
                    tokens.TotalTokens / 1_000_000m * 0.02m,
                "text-embedding-3-large" =>
                    tokens.TotalTokens / 1_000_000m * 0.13m,
                _ => 0m
            };
        }

        private decimal CalculateAnthropicCost(string model, TokenUsageInfo tokens)
        {
            return model switch
            {
                "claude-3-5-sonnet-20241022" =>
                    (tokens.InputTokens / 1_000_000m * 3.00m) +
                    (tokens.OutputTokens / 1_000_000m * 15.00m),
                "claude-3-opus-20240229" =>
                    (tokens.InputTokens / 1_000_000m * 15.00m) +
                    (tokens.OutputTokens / 1_000_000m * 75.00m),
                "claude-3-haiku-20240307" =>
                    (tokens.InputTokens / 1_000_000m * 0.25m) +
                    (tokens.OutputTokens / 1_000_000m * 1.25m),
                _ => 0m
            };
        }

        private decimal CalculateGoogleCost(string model, TokenUsageInfo tokens)
        {
            // Google Gemini pricing
            return model switch
            {
                "gemini-pro" =>
                    (tokens.InputTokens / 1_000_000m * 0.50m) +
                    (tokens.OutputTokens / 1_000_000m * 1.50m),
                "gemini-pro-vision" =>
                    (tokens.InputTokens / 1_000_000m * 0.50m) +
                    (tokens.OutputTokens / 1_000_000m * 1.50m),
                _ => 0m
            };
        }
    }
}
```

---

### 3. API Controller

```csharp
// Controllers/UserTokenCostController.cs

using Hazina.Observability.Services;
using Hazina.Observability.UserCosts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace YourApp.Controllers
{
    [ApiController]
    [Route("api/user-costs")]
    [Authorize] // Ensure user is authenticated
    public class UserTokenCostController : ControllerBase
    {
        private readonly IUserTokenCostService _costService;

        public UserTokenCostController(IUserTokenCostService costService)
        {
            _costService = costService;
        }

        /// <summary>
        /// Get total cost summary for current user
        /// </summary>
        [HttpGet("my-summary")]
        public async Task<ActionResult<UserCostSummary>> GetMyCostSummary()
        {
            var userId = User.Identity.Name; // Or however you get userId
            var summary = await _costService.GetUserTotalCostAsync(userId);
            return Ok(summary);
        }

        /// <summary>
        /// Get total cost summary for specific user (admin only)
        /// </summary>
        [HttpGet("{userId}/summary")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<UserCostSummary>> GetUserCostSummary(string userId)
        {
            var summary = await _costService.GetUserTotalCostAsync(userId);
            return Ok(summary);
        }

        /// <summary>
        /// Get detailed cost breakdown for current user
        /// </summary>
        [HttpGet("my-breakdown")]
        public async Task<ActionResult<UserCostBreakdown>> GetMyCostBreakdown(
            [FromQuery] DateTime? startDate = null,
            [FromQuery] DateTime? endDate = null)
        {
            var userId = User.Identity.Name;
            var breakdown = await _costService.GetUserCostBreakdownAsync(
                userId,
                startDate,
                endDate);
            return Ok(breakdown);
        }

        /// <summary>
        /// Get cost timeline for charting (current user)
        /// </summary>
        [HttpGet("my-timeline")]
        public async Task<ActionResult<UserCostTimeline>> GetMyCostTimeline(
            [FromQuery] DateTime? startDate = null,
            [FromQuery] DateTime? endDate = null,
            [FromQuery] string period = "daily")
        {
            var userId = User.Identity.Name;
            var start = startDate ?? DateTime.UtcNow.AddDays(-30);
            var end = endDate ?? DateTime.UtcNow;

            var timeline = await _costService.GetUserCostTimelineAsync(
                userId,
                start,
                end,
                period);
            return Ok(timeline);
        }

        /// <summary>
        /// Get top cost users (admin only)
        /// </summary>
        [HttpGet("top-users")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<List<UserCostSummary>>> GetTopCostUsers(
            [FromQuery] DateTime? startDate = null,
            [FromQuery] DateTime? endDate = null,
            [FromQuery] int limit = 10)
        {
            var topUsers = await _costService.GetTopCostUsersAsync(
                startDate,
                endDate,
                limit);
            return Ok(topUsers);
        }
    }
}
```

---

### 4. Dependency Injection Setup

```csharp
// Program.cs or Startup.cs

using Hazina.Observability.Services;

// Add to your service configuration
builder.Services.AddMemoryCache(); // For caching
builder.Services.AddScoped<IUserTokenCostService, UserTokenCostService>();

// ILLMLogRepository should already be registered if using Hazina.Observability.LLMLogs
```

---

## FRONTEND IMPLEMENTATION

### 1. TypeScript Types

```typescript
// types/userCosts.ts

export interface UserCostSummary {
  userId: string;
  totalCost: number;
  totalTokens: number;
  totalRequests: number;
  firstRequest: string; // ISO date string
  lastRequest: string;
  costByProvider: Record<string, number>;
  costByModel: Record<string, number>;
}

export interface UserCostBreakdown {
  userId: string;
  startDate: string;
  endDate: string;
  totalCost: number;
  modelBreakdown: CostByModel[];
  providerBreakdown: CostByProvider[];
  dailyBreakdown: CostByDate[];
}

export interface CostByModel {
  model: string;
  cost: number;
  tokens: number;
  requestCount: number;
  averageCostPerRequest: number;
}

export interface CostByProvider {
  provider: string;
  cost: number;
  tokens: number;
  requestCount: number;
}

export interface CostByDate {
  date: string;
  cost: number;
  tokens: number;
  requestCount: number;
}

export interface UserCostTimeline {
  userId: string;
  dataPoints: TimelineDataPoint[];
  totalCost: number;
  period: string;
}

export interface TimelineDataPoint {
  timestamp: string;
  cost: number;
  tokens: number;
  requestCount: number;
}
```

---

### 2. API Service

```typescript
// services/userCostService.ts

import axiosInstance from './axiosConfig'; // Your existing axios config
import {
  UserCostSummary,
  UserCostBreakdown,
  UserCostTimeline
} from '../types/userCosts';

export const userCostService = {
  /**
   * Get current user's total cost summary
   */
  async getMyCostSummary(): Promise<UserCostSummary> {
    const response = await axiosInstance.get('/api/user-costs/my-summary');
    return response.data;
  },

  /**
   * Get current user's detailed cost breakdown
   */
  async getMyCostBreakdown(
    startDate?: Date,
    endDate?: Date
  ): Promise<UserCostBreakdown> {
    const params = new URLSearchParams();
    if (startDate) params.append('startDate', startDate.toISOString());
    if (endDate) params.append('endDate', endDate.toISOString());

    const response = await axiosInstance.get(
      `/api/user-costs/my-breakdown?${params.toString()}`
    );
    return response.data;
  },

  /**
   * Get current user's cost timeline for charts
   */
  async getMyCostTimeline(
    startDate?: Date,
    endDate?: Date,
    period: 'hourly' | 'daily' | 'weekly' = 'daily'
  ): Promise<UserCostTimeline> {
    const params = new URLSearchParams();
    if (startDate) params.append('startDate', startDate.toISOString());
    if (endDate) params.append('endDate', endDate.toISOString());
    params.append('period', period);

    const response = await axiosInstance.get(
      `/api/user-costs/my-timeline?${params.toString()}`
    );
    return response.data;
  },

  /**
   * Get specific user's cost summary (admin only)
   */
  async getUserCostSummary(userId: string): Promise<UserCostSummary> {
    const response = await axiosInstance.get(`/api/user-costs/${userId}/summary`);
    return response.data;
  }
};
```

---

### 3. Simple Cost Display Component

```tsx
// components/UserCostDisplay.tsx

import React, { useEffect, useState } from 'react';
import { userCostService } from '../services/userCostService';
import { UserCostSummary } from '../types/userCosts';

interface UserCostDisplayProps {
  userId?: string; // Optional: for admin viewing other users
  showDetails?: boolean;
}

export const UserCostDisplay: React.FC<UserCostDisplayProps> = ({
  userId,
  showDetails = false
}) => {
  const [summary, setSummary] = useState<UserCostSummary | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadCostSummary();
  }, [userId]);

  const loadCostSummary = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = userId
        ? await userCostService.getUserCostSummary(userId)
        : await userCostService.getMyCostSummary();
      setSummary(data);
    } catch (err: any) {
      setError(err.message || 'Failed to load cost data');
      console.error('Error loading user costs:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="text-gray-500">Loading cost data...</div>;
  }

  if (error) {
    return <div className="text-red-500">Error: {error}</div>;
  }

  if (!summary) {
    return <div className="text-gray-500">No cost data available</div>;
  }

  return (
    <div className="bg-white shadow rounded-lg p-6">
      <h3 className="text-lg font-semibold mb-4">AI Usage Cost</h3>

      {/* Total Cost - Big Number */}
      <div className="mb-6">
        <div className="text-4xl font-bold text-blue-600">
          ${summary.totalCost.toFixed(4)}
        </div>
        <div className="text-sm text-gray-500 mt-1">Total lifetime cost</div>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div>
          <div className="text-2xl font-semibold">
            {summary.totalTokens.toLocaleString()}
          </div>
          <div className="text-xs text-gray-500">Total tokens</div>
        </div>
        <div>
          <div className="text-2xl font-semibold">
            {summary.totalRequests.toLocaleString()}
          </div>
          <div className="text-xs text-gray-500">API requests</div>
        </div>
      </div>

      {/* Details Section */}
      {showDetails && (
        <>
          {/* Cost by Provider */}
          <div className="mb-4">
            <h4 className="text-sm font-semibold mb-2">Cost by Provider</h4>
            {Object.entries(summary.costByProvider).map(([provider, cost]) => (
              <div key={provider} className="flex justify-between text-sm mb-1">
                <span className="text-gray-600">{provider}</span>
                <span className="font-medium">${cost.toFixed(4)}</span>
              </div>
            ))}
          </div>

          {/* Cost by Model */}
          <div>
            <h4 className="text-sm font-semibold mb-2">Cost by Model</h4>
            {Object.entries(summary.costByModel)
              .sort(([, a], [, b]) => b - a)
              .slice(0, 5) // Top 5 models
              .map(([model, cost]) => (
                <div key={model} className="flex justify-between text-sm mb-1">
                  <span className="text-gray-600 truncate">{model}</span>
                  <span className="font-medium">${cost.toFixed(4)}</span>
                </div>
              ))}
          </div>
        </>
      )}

      {/* Last Updated */}
      <div className="mt-6 text-xs text-gray-400 border-t pt-3">
        Last request: {new Date(summary.lastRequest).toLocaleString()}
      </div>
    </div>
  );
};
```

---

### 4. Cost Timeline Chart Component

```tsx
// components/UserCostChart.tsx

import React, { useEffect, useState } from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';
import { userCostService } from '../services/userCostService';
import { UserCostTimeline } from '../types/userCosts';

interface UserCostChartProps {
  dateRange?: { start: Date; end: Date };
  period?: 'hourly' | 'daily' | 'weekly';
}

export const UserCostChart: React.FC<UserCostChartProps> = ({
  dateRange = {
    start: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
    end: new Date()
  },
  period = 'daily'
}) => {
  const [timeline, setTimeline] = useState<UserCostTimeline | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadTimeline();
  }, [dateRange, period]);

  const loadTimeline = async () => {
    setLoading(true);
    try {
      const data = await userCostService.getMyCostTimeline(
        dateRange.start,
        dateRange.end,
        period
      );
      setTimeline(data);
    } catch (err) {
      console.error('Error loading timeline:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div>Loading chart...</div>;
  if (!timeline || timeline.dataPoints.length === 0) {
    return <div>No data available for this period</div>;
  }

  const chartData = timeline.dataPoints.map(point => ({
    date: new Date(point.timestamp).toLocaleDateString(),
    cost: parseFloat(point.cost.toFixed(4)),
    tokens: point.tokens,
    requests: point.requestCount
  }));

  return (
    <div className="bg-white shadow rounded-lg p-6">
      <h3 className="text-lg font-semibold mb-4">
        Cost Over Time ({period})
      </h3>
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="date" />
          <YAxis
            label={{ value: 'Cost ($)', angle: -90, position: 'insideLeft' }}
          />
          <Tooltip
            formatter={(value: number) => `$${value.toFixed(4)}`}
          />
          <Legend />
          <Line
            type="monotone"
            dataKey="cost"
            stroke="#3b82f6"
            strokeWidth={2}
            dot={{ r: 4 }}
          />
        </LineChart>
      </ResponsiveContainer>
      <div className="mt-4 text-sm text-gray-500 text-center">
        Total: ${timeline.totalCost.toFixed(4)} over {timeline.dataPoints.length} {period} periods
      </div>
    </div>
  );
};
```

---

## INTEGRATION EXAMPLES

### For ArtRevisionist

```tsx
// ArtRevisionist/Frontend/src/pages/Settings.tsx

import { UserCostDisplay } from '../components/UserCostDisplay';
import { UserCostChart } from '../components/UserCostChart';

export const SettingsPage = () => {
  return (
    <div className="container mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">Account Settings</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Simple Cost Display */}
        <UserCostDisplay showDetails={true} />

        {/* Cost Chart */}
        <UserCostChart period="daily" />
      </div>
    </div>
  );
};
```

### For Client-Manager

```tsx
// ClientManager/Frontend/src/pages/Billing.tsx

import { UserCostDisplay } from '../components/UserCostDisplay';
import { UserCostChart } from '../components/UserCostChart';

export const BillingPage = () => {
  const [dateRange, setDateRange] = useState({
    start: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
    end: new Date()
  });

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">AI Usage & Billing</h1>

      {/* Month selector */}
      <div className="mb-6">
        {/* Add date range picker here */}
      </div>

      {/* Cost widgets */}
      <div className="space-y-6">
        <UserCostDisplay showDetails={true} />
        <UserCostChart dateRange={dateRange} period="daily" />
      </div>
    </div>
  );
};
```

---

## SIMPLE INLINE USAGE (NO SEPARATE PAGE NEEDED)

### Show cost in header/navbar

```tsx
// components/Navbar.tsx

import { useEffect, useState } from 'react';
import { userCostService } from '../services/userCostService';

export const Navbar = () => {
  const [totalCost, setTotalCost] = useState<number | null>(null);

  useEffect(() => {
    // Load once on mount
    userCostService.getMyCostSummary()
      .then(summary => setTotalCost(summary.totalCost))
      .catch(err => console.error('Failed to load cost:', err));
  }, []);

  return (
    <nav className="bg-gray-800 text-white p-4 flex justify-between">
      <div>My App</div>
      <div className="text-sm">
        {totalCost !== null && (
          <span className="bg-gray-700 px-3 py-1 rounded">
            AI Cost: ${totalCost.toFixed(4)}
          </span>
        )}
      </div>
    </nav>
  );
};
```

---

## INSTALLATION CHECKLIST

### Backend (5 minutes)

1. **Copy service files to your project:**
   - `Models/UserTokenCostModels.cs`
   - `Services/UserTokenCostService.cs`
   - `Controllers/UserTokenCostController.cs`

2. **Register in Program.cs:**
   ```csharp
   builder.Services.AddMemoryCache();
   builder.Services.AddScoped<IUserTokenCostService, UserTokenCostService>();
   ```

3. **Build and run:**
   ```bash
   dotnet build
   dotnet run
   ```

4. **Test endpoint:**
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:5000/api/user-costs/my-summary
   ```

### Frontend (10 minutes)

1. **Install recharts (if not installed):**
   ```bash
   npm install recharts
   ```

2. **Copy files:**
   - `types/userCosts.ts`
   - `services/userCostService.ts`
   - `components/UserCostDisplay.tsx`
   - `components/UserCostChart.tsx`

3. **Add to your page:**
   ```tsx
   import { UserCostDisplay } from '../components/UserCostDisplay';

   // In your component:
   <UserCostDisplay showDetails={true} />
   ```

4. **Done!** Cost tracking is now visible to users.

---

## PRICING UPDATE GUIDE

**Update costs quarterly** in `UserTokenCostService.cs`:

```csharp
private decimal CalculateOpenAICost(string model, TokenUsageInfo tokens)
{
    // Check OpenAI pricing page: https://openai.com/pricing
    // Last updated: 2026-01-12
    return model switch
    {
        "gpt-4o" =>
            (tokens.InputTokens / 1_000_000m * 2.50m) +  // ← Update here
            (tokens.OutputTokens / 1_000_000m * 10.00m), // ← And here
        // ... rest of models
    };
}
```

**Add new models:**
```csharp
"gpt-5" =>
    (tokens.InputTokens / 1_000_000m * 5.00m) +
    (tokens.OutputTokens / 1_000_000m * 15.00m),
```

---

## ADVANCED: BUDGET ALERTS

```csharp
// Add to UserTokenCostService

public async Task<BudgetStatus> GetBudgetStatusAsync(
    string userId,
    decimal monthlyBudget)
{
    var startOfMonth = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);
    var breakdown = await GetUserCostBreakdownAsync(userId, startOfMonth, DateTime.UtcNow);

    var percentUsed = (breakdown.TotalCost / monthlyBudget) * 100;

    return new BudgetStatus
    {
        MonthlyBudget = monthlyBudget,
        CurrentSpend = breakdown.TotalCost,
        RemainingBudget = monthlyBudget - breakdown.TotalCost,
        PercentUsed = percentUsed,
        AlertLevel = percentUsed switch
        {
            >= 100 => AlertLevel.Critical,
            >= 80 => AlertLevel.Warning,
            >= 50 => AlertLevel.Info,
            _ => AlertLevel.Normal
        }
    };
}
```

---

## SUCCESS CRITERIA

**You have successfully integrated per-user cost tracking ONLY IF:**

✅ Users can see their total AI cost in the UI
✅ Cost data updates within 5 minutes (cache TTL)
✅ Cost breakdown shows by provider and model
✅ Timeline chart displays cost over time
✅ No performance impact (caching + efficient queries)
✅ Works in both ArtRevisionist and Client-Manager

---

**Total Implementation Time:** 15-30 minutes per application
**Maintenance:** Update pricing quarterly, add new models as released


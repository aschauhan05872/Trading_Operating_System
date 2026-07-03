# Architecture

## Overview
The project is organized around a clean, modular architecture in which each responsibility is isolated into dedicated MQL5 include modules.

## Module Responsibilities
- ConfigManager: configuration loading and runtime settings.
- RiskManager: guardrail and risk-rule orchestration.
- LotManager: position sizing and lot calculations.
- TradeManager: execution and trade-state coordination.
- LockManager: lockout and safety-state coordination.
- CooldownManager: cooldown handling between actions.
- DailyLimitManager: daily exposure and loss limits.
- StatisticsManager: data collection and reporting hooks.
- EmergencyManager: emergency shutdown and protective actions.
- DashboardManager: monitoring and display integration.

## Design Principles
- Separation of concerns.
- Expandable module boundaries.
- Explicit, readable MQL5 structure.
- No business logic in the initial scaffold.

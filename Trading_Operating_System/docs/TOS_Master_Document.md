# Trading Operating System (TOS)

## Project Vision

Trading Operating System (TOS) is not a trading bot.

Its purpose is to become an institutional-grade trading discipline and
execution framework that:

-   Protects trading capital.
-   Eliminates emotional decisions.
-   Collects structured trading knowledge.
-   Learns trader behavior.
-   Builds an AI trading assistant.
-   Eventually supports semi-automated execution.

The system is designed around one core belief:

> "The biggest enemy is not the market. It is inconsistent execution."

## Core Philosophy

### What TOS Will Do

-   Enforce discipline.
-   Protect account equity.
-   Prevent overtrading.
-   Prevent revenge trading.
-   Prevent FOMO entries.
-   Collect high-quality trade data.
-   Learn from historical trades.
-   Assist future decisions.

### What TOS Will NOT Do

-   Predict markets immediately.
-   Automatically trade immediately.
-   Chase holy grail indicators.
-   Add random filters every week.
-   Change strategy every month.

## Development Principles

1.  Complete current phase before starting next phase.
2.  No skipping phases.
3.  No adding features outside roadmap.
4.  Every phase requires validation period.
5.  Data first, AI second.
6.  Discipline first, automation second.

## Technology Stack

### Trading Platform

-   MetaTrader 5
-   Hedging Account Support
-   Broker Agnostic Architecture

### Phase 1

-   MQL5
-   MT5 Expert Advisor
-   Local CSV Storage

### Phase 2

-   SQLite or PostgreSQL
-   Python Analytics Engine
-   REST API Layer

### Phase 3+

-   Python AI Services
-   Machine Learning Pipeline
-   Historical Trade Database

### Future Stack

-   Python
-   FastAPI
-   PostgreSQL
-   Vector Database
-   Docker
-   Cloud Deployment

## System Architecture

Trader → TOS → Risk Engine → Execution Engine → Trade Journal →
Analytics Engine → AI Learning Engine → AI Decision Assistant

# Phase 1 - Risk Manager EA

## Objective

Prevent account destruction caused by emotional decisions while
preserving trader discretion.

### Rules

-   Dynamic daily drawdown based on highest equity reached during the
    day.
-   Daily loss limit: 10%.
-   Maximum losing trades per day: 3.
-   Losing trade = realized PnL below zero.
-   Breakeven and profitable stop exits do not count as losses.
-   Maximum open trades: 1.
-   Cooldown after trade close: 30 minutes.
-   Emergency close lock: 2 hours.
-   Dynamic risk per trade based on account equity.
-   Minimum RR: 1:2.
-   Dashboard position: Top Right.

### Trade Protection

-   SL may only move toward reducing risk.
-   TP may only move toward increasing reward.
-   Automatic breakeven at 50% of target reached.
-   Manual discretion preserved within risk rules.

## Phase 1 Success Criteria

-   30 trading days
-   50 trades minimum
-   No rule violations
-   Stable execution

# Phase 2 - Trade Journal Engine

-   Capture entry, exit, RR, lot, duration and result.
-   Mandatory strategy tagging.
-   Minimum 100 recorded trades.

# Phase 3 - Market Context Collection

-   Chart screenshots
-   Indicator state
-   Liquidity levels
-   EMA values
-   Market session
-   Volatility

Minimum 200 fully captured trades.

# Phase 4 - Analytics Engine

-   Best setup
-   Best RR
-   Best session
-   Worst setup
-   Statistical analysis

# Phase 5 - AI Learning Engine

AI learns: - Winning patterns - Losing patterns - FOMO patterns -
Revenge trading behavior - Overtrading behavior

# Phase 6 - AI Trade Validator

AI scores new trades based on historical similarity and performance.

# Phase 7 - AI Assistant

AI suggests: - Better entries - Better timing - Better RR - Better trade
selection

# Phase 8 - Semi Automated Execution

Requirements: - 500+ trades - Positive expectancy - Stable AI scoring

## Future Possibilities

-   Prop firm profiles
-   FTMO mode
-   FundedNext mode
-   Mobile dashboard
-   Cloud analytics
-   Telegram alerts
-   Discord alerts

## Mission Statement

Transform trading from:

Emotion → Decision → Loss

into:

Rules → Execution → Statistics → Improvement

The goal is not to predict every move.

The goal is to survive long enough for the edge to compound.

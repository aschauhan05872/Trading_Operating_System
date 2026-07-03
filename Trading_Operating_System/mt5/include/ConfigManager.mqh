//+------------------------------------------------------------------+
//|                                                   ConfigManager.mqh
//| Purpose: Centralized storage for Trading Operating System (TOS)
//|          Phase 1 configuration values.
//+------------------------------------------------------------------+
#property strict

class ConfigManager
{
private:

   // ================================================================
   // ACCOUNT PROTECTION SETTINGS
   // ================================================================

   double m_daily_drawdown_limit_percent;
   bool   m_enable_dynamic_daily_drawdown;

   int    m_max_losing_trades_per_day;

   int    m_cooldown_minutes;

   // ================================================================
   // RISK MANAGEMENT SETTINGS
   // ================================================================

   double m_risk_per_trade_percent;

   double m_min_rr;

   double m_breakeven_trigger_percent;

   // ================================================================
   // POSITION MANAGEMENT SETTINGS
   // ================================================================

   int    m_max_open_trades;

   bool   m_dynamic_lot_scaling_enabled;

   // ================================================================
   // DASHBOARD SETTINGS
   // ================================================================

   bool   m_dashboard_enabled;

   string m_dashboard_position;

   // ================================================================
   // EMERGENCY SETTINGS
   // ================================================================

   int    m_emergency_lock_duration_minutes;

   // ================================================================
   // TRADE PROTECTION SETTINGS
   // ================================================================

   bool   m_enable_trade_lock;

   bool   m_enable_auto_breakeven;

   bool   m_enable_emergency_close;

   bool   m_enable_sl_risk_reduction_only;

   bool   m_enable_tp_reward_increase_only;

public:

   ConfigManager()
   {
      LoadDefaults();
   }

   void LoadDefaults()
   {
      // ============================================================
      // ACCOUNT PROTECTION
      // ============================================================

      m_daily_drawdown_limit_percent = 10.0;

      m_enable_dynamic_daily_drawdown = true;

      m_max_losing_trades_per_day = 3;

      m_cooldown_minutes = 30;

      // ============================================================
      // RISK MANAGEMENT
      // ============================================================

      m_risk_per_trade_percent = 2.0;

      m_min_rr = 2.0;

      m_breakeven_trigger_percent = 50.0;

      // ============================================================
      // POSITION MANAGEMENT
      // ============================================================

      m_max_open_trades = 1;

      m_dynamic_lot_scaling_enabled = true;

      // ============================================================
      // DASHBOARD
      // ============================================================

      m_dashboard_enabled = true;

      m_dashboard_position = "TopRight";

      // ============================================================
      // EMERGENCY SETTINGS
      // ============================================================

      m_emergency_lock_duration_minutes = 120;

      // ============================================================
      // TRADE PROTECTION
      // ============================================================

      m_enable_trade_lock = true;

      m_enable_auto_breakeven = true;

      m_enable_emergency_close = true;

      m_enable_sl_risk_reduction_only = true;

      m_enable_tp_reward_increase_only = true;
   }

   // ================================================================
   // ACCOUNT PROTECTION GETTERS
   // ================================================================

   double GetDailyDrawdownLimitPercent()
   {
      return m_daily_drawdown_limit_percent;
   }

   bool IsDynamicDailyDrawdownEnabled()
   {
      return m_enable_dynamic_daily_drawdown;
   }

   int GetMaxLosingTradesPerDay()
   {
      return m_max_losing_trades_per_day;
   }

   int GetCooldownMinutes()
   {
      return m_cooldown_minutes;
   }

   // ================================================================
   // RISK MANAGEMENT GETTERS
   // ================================================================

   double GetRiskPerTradePercent()
   {
      return m_risk_per_trade_percent;
   }

   double GetMinimumRR()
   {
      return m_min_rr;
   }

   double GetBreakevenTriggerPercent()
   {
      return m_breakeven_trigger_percent;
   }

   // ================================================================
   // POSITION MANAGEMENT GETTERS
   // ================================================================

   int GetMaxOpenTrades()
   {
      return m_max_open_trades;
   }

   bool IsDynamicLotScalingEnabled()
   {
      return m_dynamic_lot_scaling_enabled;
   }

   // ================================================================
   // DASHBOARD GETTERS
   // ================================================================

   bool IsDashboardEnabled()
   {
      return m_dashboard_enabled;
   }

   string GetDashboardPosition()
   {
      return m_dashboard_position;
   }

   // ================================================================
   // EMERGENCY GETTERS
   // ================================================================

   int GetEmergencyLockDurationMinutes()
   {
      return m_emergency_lock_duration_minutes;
   }

   // ================================================================
   // TRADE PROTECTION GETTERS
   // ================================================================

   bool IsTradeLockEnabled()
   {
      return m_enable_trade_lock;
   }

   bool IsAutoBreakevenEnabled()
   {
      return m_enable_auto_breakeven;
   }

   bool IsEmergencyCloseEnabled()
   {
      return m_enable_emergency_close;
   }

   bool IsSLRiskReductionOnlyEnabled()
   {
      return m_enable_sl_risk_reduction_only;
   }

   bool IsTPRewardIncreaseOnlyEnabled()
   {
      return m_enable_tp_reward_increase_only;
   }
};
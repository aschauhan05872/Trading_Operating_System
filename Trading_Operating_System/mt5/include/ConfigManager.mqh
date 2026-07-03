//+------------------------------------------------------------------+
//|                                                   ConfigManager.mqh |
//| Purpose: Centralized storage for Phase 1 user-configurable MT5   |
//|          trading parameters.                                     |
//+------------------------------------------------------------------+
#property strict

class ConfigManager
{
private:
   double            m_daily_loss_percent;
   int               m_max_trades_per_day;
   int               m_consecutive_loss_limit;
   int               m_cooldown_minutes;

   double            m_risk_per_trade_percent;
   double            m_min_rr;
   double            m_breakeven_trigger_percent;

   int               m_max_open_trades;
   bool              m_dynamic_lot_scaling_enabled;

   bool              m_dashboard_enabled;
   string            m_dashboard_position;

   int               m_emergency_lock_duration_minutes;
   bool              m_enable_trade_lock;
   bool              m_enable_auto_breakeven;
   bool              m_enable_emergency_close;

public:
   ConfigManager()
   {
      LoadDefaults();
   }

   void LoadDefaults()
   {
      m_daily_loss_percent = 10.0;
      m_max_trades_per_day = 5;
      m_consecutive_loss_limit = 3;
      m_cooldown_minutes = 30;

      m_risk_per_trade_percent = 3.0;
      m_min_rr = 2;
      m_breakeven_trigger_percent = 50.0;

      m_max_open_trades = 1;
      m_dynamic_lot_scaling_enabled = true;

      m_dashboard_enabled = true;
      m_dashboard_position = "BottomRight";

      m_emergency_lock_duration_minutes = 120;
      m_enable_trade_lock = true;
      m_enable_auto_breakeven = true;
      m_enable_emergency_close = true;
   }

   double GetDailyLossPercent()
   {
      return m_daily_loss_percent;
   }

   int GetMaxTradesPerDay()
   {
      return m_max_trades_per_day;
   }

   int GetConsecutiveLossLimit()
   {
      return m_consecutive_loss_limit;
   }

   int GetCooldownMinutes()
   {
      return m_cooldown_minutes;
   }

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

   int GetMaxOpenTrades()
   {
      return m_max_open_trades;
   }

   bool IsDynamicLotScalingEnabled()
   {
      return m_dynamic_lot_scaling_enabled;
   }

   bool IsDashboardEnabled()
   {
      return m_dashboard_enabled;
   }

   string GetDashboardPosition()
   {
      return m_dashboard_position;
   }

   int GetEmergencyLockDurationMinutes()
   {
      return m_emergency_lock_duration_minutes;
   }
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
};

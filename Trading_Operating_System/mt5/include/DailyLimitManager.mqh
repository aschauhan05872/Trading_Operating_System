//+------------------------------------------------------------------+
//|                                          DailyLimitManager.mqh   |
//| Purpose: Track daily equity, drawdown lock level and daily loss  |
//| count for Trading Operating System Phase 1 protection rules.     |
//+------------------------------------------------------------------+
#property strict

#include "ConfigManager.mqh"

class DailyLimitManager
{
private:
   ConfigManager* m_config;

   double m_start_of_day_equity;
   double m_peak_equity_today;
   double m_daily_lock_level;

   int    m_daily_loss_count;
   int    m_last_day_index;

   bool   m_is_initialized;

public:

   DailyLimitManager(ConfigManager* config)
   {
      m_config = config;
      Initialize();
   }

   void Initialize()
   {
      m_start_of_day_equity = 0.0;
      m_peak_equity_today   = 0.0;
      m_daily_lock_level    = 0.0;

      m_daily_loss_count    = 0;
      m_last_day_index      = 0;

      m_is_initialized      = false;
   }

   void Update()
   {
      int current_day_index = (int)(TimeCurrent() / 86400);

      // New trading day detected
      if(m_is_initialized && current_day_index != m_last_day_index)
      {
         ResetForNewDay();
         return;
      }

      // First initialization
      if(!m_is_initialized)
      {
         ResetForNewDay();
         return;
      }

      double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);

      // Update peak equity
      if(current_equity > m_peak_equity_today)
      {
         m_peak_equity_today = current_equity;
      }

      // Dynamic floating daily drawdown
      m_daily_lock_level =
         m_peak_equity_today *
         (1.0 - (m_config->GetDailyDrawdownLimitPercent() / 100.0));
   }

   void ResetForNewDay()
   {
      m_start_of_day_equity =
         AccountInfoDouble(ACCOUNT_EQUITY);

      m_peak_equity_today =
         m_start_of_day_equity;

      m_daily_lock_level =
         m_peak_equity_today *
         (1.0 - (m_config->GetDailyDrawdownLimitPercent() / 100.0));

      m_daily_loss_count = 0;

      m_last_day_index =
         (int)(TimeCurrent() / 86400);

      m_is_initialized = true;
   }

   // Only negative realized trades count as losses
   void RecordTradeResult(double realized_profit)
   {
      if(realized_profit < 0.0)
      {
         m_daily_loss_count++;
      }
   }

   double GetStartOfDayEquity()
   {
      return m_start_of_day_equity;
   }

   double GetPeakEquityToday()
   {
      return m_peak_equity_today;
   }

   double GetCurrentEquity()
   {
      return AccountInfoDouble(ACCOUNT_EQUITY);
   }

   double GetDailyLockLevel()
   {
      return m_daily_lock_level;
   }

   // Remaining amount account can lose before lock
   double GetRemainingDailyLoss()
   {
      return AccountInfoDouble(ACCOUNT_EQUITY)
             - m_daily_lock_level;
   }

   int GetDailyLossCount()
   {
      return m_daily_loss_count;
   }

   double GetCurrentDrawdown()
   {
      return m_peak_equity_today
             - AccountInfoDouble(ACCOUNT_EQUITY);
   }

   double GetDrawdownPercentage()
   {
      if(m_peak_equity_today <= 0.0)
         return 0.0;

      return
         (GetCurrentDrawdown() /
          m_peak_equity_today) * 100.0;
   }

   bool IsDailyDrawdownReached()
   {
      return
         AccountInfoDouble(ACCOUNT_EQUITY)
         < m_daily_lock_level;
   }

   bool IsDailyLossCountReached()
   {
      return
         m_daily_loss_count
         >= m_config->GetMaxLosingTradesPerDay();
   }

   bool CanTradeToday()
   {
      if(!m_is_initialized)
         return true;

      if(IsDailyDrawdownReached())
         return false;

      if(IsDailyLossCountReached())
         return false;

      return true;
   }
};
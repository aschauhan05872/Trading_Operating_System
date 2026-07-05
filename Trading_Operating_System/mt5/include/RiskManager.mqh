//+------------------------------------------------------------------+
//|                                                   RiskManager.mqh |
//| Purpose: Central trade validation engine for TOS Phase 1         |
//+------------------------------------------------------------------+
#property strict

#include "ConfigManager.mqh"
#include "DailyLimitManager.mqh"
#include "CooldownManager.mqh"
#include "LotManager.mqh"

class RiskManager
{
private:
   ConfigManager*      m_config;
   DailyLimitManager*  m_daily_limit;
   CooldownManager*    m_cooldown;
   LotManager*         m_lot_manager;

   string              m_last_rejection_reason;

public:

   RiskManager(
      ConfigManager* config,
      DailyLimitManager* daily_limit,
      CooldownManager* cooldown,
      LotManager* lot_manager)
   {
      m_config = config;
      m_daily_limit = daily_limit;
      m_cooldown = cooldown;
      m_lot_manager = lot_manager;

      m_last_rejection_reason = "";
   }

   void Initialize()
   {
      m_last_rejection_reason = "";
   }

   bool CanOpenTrade(
      double requested_lot,
      double stop_loss_points,
      double take_profit_points)
   {
      m_last_rejection_reason = "";

      if(!ValidateDailyLimits())
         return false;

      if(!ValidateCooldown())
         return false;

      if(!ValidateOpenPositions())
         return false;

      if(!ValidateLotSize(requested_lot))
         return false;

      if(!ValidateRisk(requested_lot, stop_loss_points))
         return false;

      if(!ValidateRR(stop_loss_points, take_profit_points))
         return false;

      return true;
   }

   string GetLastRejectionReason()
   {
      return m_last_rejection_reason;
   }

private:

   bool ValidateDailyLimits()
   {
      if(m_daily_limit == NULL)
      {
         m_last_rejection_reason =
            "Daily limit manager not initialized.";
         return false;
      }

      if(m_daily_limit->IsDailyDrawdownReached())
      {
         m_last_rejection_reason =
            "Daily drawdown limit reached.";
         return false;
      }

      if(m_daily_limit->IsDailyLossCountReached())
      {
         m_last_rejection_reason =
            "Maximum losing trades reached for today.";
         return false;
      }

      return true;
   }

   bool ValidateCooldown()
   {
      if(m_cooldown == NULL)
      {
         m_last_rejection_reason =
            "Cooldown manager not initialized.";
         return false;
      }

      if(m_cooldown->IsCooldownActive())
      {
         int remaining_seconds =
            m_cooldown->GetRemainingCooldownSeconds();

         int remaining_minutes =
            (remaining_seconds + 59) / 60;

         m_last_rejection_reason =
            StringFormat(
               "Cooldown active: %d minute(s) remaining.",
               remaining_minutes);

         return false;
      }

      return true;
   }

   bool ValidateOpenPositions()
   {
      if(m_config == NULL || m_lot_manager == NULL)
      {
         m_last_rejection_reason =
            "Position validation dependencies missing.";
         return false;
      }

      int open_positions = 0;

      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);

         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetString(POSITION_SYMBOL) ==
               m_lot_manager->GetSymbol())
            {
               open_positions++;
            }
         }
      }

      if(open_positions >= m_config->GetMaxOpenTrades())
      {
         m_last_rejection_reason =
            StringFormat(
               "Maximum open positions reached (%d).",
               m_config->GetMaxOpenTrades());

         return false;
      }

      return true;
   }

   bool ValidateLotSize(double requested_lot)
   {
      if(m_lot_manager == NULL)
      {
         m_last_rejection_reason =
            "Lot manager not initialized.";
         return false;
      }

      if(requested_lot <= 0)
      {
         m_last_rejection_reason =
            "Requested lot must be greater than zero.";
         return false;
      }

      double max_allowed =
         m_lot_manager->GetMaximumAllowedLot();

      if(requested_lot > max_allowed)
      {
         m_last_rejection_reason =
            StringFormat(
               "Requested lot %.2f exceeds maximum allowed %.2f.",
               requested_lot,
               max_allowed);

         return false;
      }

      if(!m_lot_manager->CanTradeLot(requested_lot))
      {
         m_last_rejection_reason =
            "Requested lot violates symbol volume rules.";
         return false;
      }

      return true;
   }

   bool ValidateRisk(
      double requested_lot,
      double stop_loss_points)
   {
      if(stop_loss_points <= 0)
      {
         m_last_rejection_reason =
            "Stop loss distance must be greater than zero.";
         return false;
      }

      double allowed_risk =
         m_lot_manager->GetCurrentRiskAmount();

      double actual_risk =
         m_lot_manager->CalculateRiskAmount(
            requested_lot,
            stop_loss_points);

      if(actual_risk > allowed_risk)
      {
         m_last_rejection_reason =
            StringFormat(
               "Risk %.2f exceeds allowed %.2f.",
               actual_risk,
               allowed_risk);

         return false;
      }

      return true;
   }

   bool ValidateRR(
      double stop_loss_points,
      double take_profit_points)
   {
      if(stop_loss_points <= 0 ||
         take_profit_points <= 0)
      {
         m_last_rejection_reason =
            "Invalid SL or TP distance.";
         return false;
      }

      double rr =
         take_profit_points / stop_loss_points;

      if(rr < m_config->GetMinimumRR())
      {
         m_last_rejection_reason =
            StringFormat(
               "RR %.2f below minimum %.2f.",
               rr,
               m_config->GetMinimumRR());

         return false;
      }

      return true;
   }

public:

   double GetCurrentRiskAmount()
   {
      if(m_lot_manager == NULL)
         return 0.0;

      return m_lot_manager->GetCurrentRiskAmount();
   }
};
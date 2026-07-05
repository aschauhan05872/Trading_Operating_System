//+------------------------------------------------------------------+
//|                                       TradeProtectionManager.mqh |
//| Purpose: Validate one-way trade protection rules for TOS Phase 1 |
//+------------------------------------------------------------------+
#property strict

#include "ConfigManager.mqh"

class TradeProtectionManager
{
private:
   ConfigManager* m_config;
   string         m_last_rejection_reason;

public:

   TradeProtectionManager(ConfigManager* config)
   {
      m_config = config;
      Initialize();
   }

   void Initialize()
   {
      m_last_rejection_reason = "";
   }

   bool CanModifyStopLoss(
      ENUM_POSITION_TYPE position_type,
      double current_sl,
      double proposed_sl)
   {
      m_last_rejection_reason = "";

      if(m_config == NULL)
      {
         m_last_rejection_reason =
            "Config manager not initialized.";
         return false;
      }

      // Feature disabled -> always allow
      if(!m_config->IsSLRiskReductionOnlyEnabled())
         return true;

      if(current_sl <= 0.0 || proposed_sl <= 0.0)
      {
         m_last_rejection_reason =
            "Stop loss values must be greater than zero.";

         return false;
      }

      if(position_type == POSITION_TYPE_BUY)
      {
         // BUY SL can only move upward
         if(proposed_sl < current_sl)
         {
            m_last_rejection_reason =
               "Stop loss can only move toward reducing risk.";

            return false;
         }
      }
      else if(position_type == POSITION_TYPE_SELL)
      {
         // SELL SL can only move downward
         if(proposed_sl > current_sl)
         {
            m_last_rejection_reason =
               "Stop loss can only move toward reducing risk.";

            return false;
         }
      }
      else
      {
         m_last_rejection_reason =
            "Invalid position type.";

         return false;
      }

      return true;
   }

   bool CanModifyTakeProfit(
      ENUM_POSITION_TYPE position_type,
      double current_tp,
      double proposed_tp)
   {
      m_last_rejection_reason = "";

      if(m_config == NULL)
      {
         m_last_rejection_reason =
            "Config manager not initialized.";

         return false;
      }

      // Feature disabled -> always allow
      if(!m_config->IsTPRewardIncreaseOnlyEnabled())
         return true;

      if(current_tp <= 0.0 || proposed_tp <= 0.0)
      {
         m_last_rejection_reason =
            "Take profit values must be greater than zero.";

         return false;
      }

      if(position_type == POSITION_TYPE_BUY)
      {
         // BUY TP can only move upward
         if(proposed_tp < current_tp)
         {
            m_last_rejection_reason =
               "Take profit can only move toward increasing reward.";

            return false;
         }
      }
      else if(position_type == POSITION_TYPE_SELL)
      {
         // SELL TP can only move downward
         if(proposed_tp > current_tp)
         {
            m_last_rejection_reason =
               "Take profit can only move toward increasing reward.";

            return false;
         }
      }
      else
      {
         m_last_rejection_reason =
            "Invalid position type.";

         return false;
      }

      return true;
   }

   bool ShouldMoveToBreakeven(
      ENUM_POSITION_TYPE position_type,
      double entry_price,
      double current_price,
      double stop_loss,
      double take_profit)
   {
      if(m_config == NULL)
         return false;

      if(!m_config->IsAutoBreakevenEnabled())
         return false;

      if(entry_price <= 0.0 ||
         current_price <= 0.0 ||
         stop_loss <= 0.0 ||
         take_profit <= 0.0)
      {
         return false;
      }

      double target_distance =
         MathAbs(take_profit - entry_price);

      if(target_distance <= 0.0)
         return false;

      double trigger_percent =
         m_config->GetBreakevenTriggerPercent();

      double trigger_distance =
         target_distance *
         trigger_percent / 100.0;

      if(position_type == POSITION_TYPE_BUY)
      {
         return
            (current_price - entry_price)
            >= trigger_distance;
      }

      if(position_type == POSITION_TYPE_SELL)
      {
         return
            (entry_price - current_price)
            >= trigger_distance;
      }

      return false;
   }

   double GetBreakevenPrice(
      double entry_price)
   {
      // TODO:
      // Future enhancement:
      // Include spread and commission compensation.

      return entry_price;
   }

   string GetLastRejectionReason()
   {
      return m_last_rejection_reason;
   }
};
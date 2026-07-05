//+------------------------------------------------------------------+
//|                                                   TradeManager.mqh |
//| Purpose: Execute approved trades and manage position operations. |
//+------------------------------------------------------------------+
#property strict

#include "ConfigManager.mqh"
#include "RiskManager.mqh"
#include "TradeProtectionManager.mqh"
#include "CooldownManager.mqh"
#include "LotManager.mqh"
#include <Trade\Trade.mqh>

class TradeManager
{
private:
   ConfigManager*          m_config;
   RiskManager*            m_risk_manager;
   TradeProtectionManager* m_trade_protection;
   CooldownManager*        m_cooldown;
   LotManager*             m_lot_manager;

   CTrade                  m_trade;

   string                  m_last_error_message;
   string                  m_symbol;

public:

   TradeManager(
      ConfigManager* config,
      RiskManager* risk_manager,
      TradeProtectionManager* trade_protection,
      CooldownManager* cooldown,
      LotManager* lot_manager)
   {
      m_config = config;
      m_risk_manager = risk_manager;
      m_trade_protection = trade_protection;
      m_cooldown = cooldown;
      m_lot_manager = lot_manager;

      m_last_error_message = "";

      m_symbol =
         (m_lot_manager != NULL)
         ? m_lot_manager.GetSymbol()
         : "";
   }

   void Initialize()
   {
      m_last_error_message = "";

      if(m_risk_manager != NULL)
         m_risk_manager.Initialize();

      if(m_trade_protection != NULL)
         m_trade_protection.Initialize();

      if(m_cooldown != NULL)
         m_cooldown.Initialize();
   }

   bool OpenBuy(
      double lot,
      double sl_price,
      double tp_price,
      string comment)
   {
      m_last_error_message = "";

      if(m_symbol == "")
      {
         m_last_error_message =
            "Trading symbol not configured.";

         return false;
      }

      double entry_price =
         SymbolInfoDouble(m_symbol, SYMBOL_ASK);

      double stop_loss_points =
         CalculateDistancePoints(entry_price, sl_price);

      double take_profit_points =
         CalculateDistancePoints(entry_price, tp_price);

      if(!ValidateTradeRequest(
            lot,
            stop_loss_points,
            take_profit_points))
      {
         return false;
      }

      bool result =
         m_trade.Buy(
            lot,
            m_symbol,
            0.0,
            sl_price,
            tp_price,
            comment);

      if(!result)
      {
         m_last_error_message =
            StringFormat(
               "Broker rejected BUY order: %s",
               m_trade.ResultRetcodeDescription());

         return false;
      }

      return true;
   }

   bool OpenSell(
      double lot,
      double sl_price,
      double tp_price,
      string comment)
   {
      m_last_error_message = "";

      if(m_symbol == "")
      {
         m_last_error_message =
            "Trading symbol not configured.";

         return false;
      }

      double entry_price =
         SymbolInfoDouble(m_symbol, SYMBOL_BID);

      double stop_loss_points =
         CalculateDistancePoints(sl_price, entry_price);

      double take_profit_points =
         CalculateDistancePoints(entry_price, tp_price);

      if(!ValidateTradeRequest(
            lot,
            stop_loss_points,
            take_profit_points))
      {
         return false;
      }

      bool result =
         m_trade.Sell(
            lot,
            m_symbol,
            0.0,
            sl_price,
            tp_price,
            comment);

      if(!result)
      {
         m_last_error_message =
            StringFormat(
               "Broker rejected SELL order: %s",
               m_trade.ResultRetcodeDescription());

         return false;
      }

      return true;
   }

   bool ModifyStopLoss(
      ulong ticket,
      double new_sl)
   {
      m_last_error_message = "";

      if(!PositionSelectByTicket(ticket))
      {
         m_last_error_message =
            "Position not found.";

         return false;
      }

      ENUM_POSITION_TYPE position_type =
         (ENUM_POSITION_TYPE)
         PositionGetInteger(POSITION_TYPE);

      double current_sl =
         PositionGetDouble(POSITION_SL);

      if(!m_trade_protection.CanModifyStopLoss(
            position_type,
            current_sl,
            new_sl))
      {
         m_last_error_message =
            m_trade_protection.GetLastRejectionReason();

         return false;
      }

      string symbol =
         PositionGetString(POSITION_SYMBOL);

      bool result =
         m_trade.PositionModify(
            symbol,
            new_sl,
            PositionGetDouble(POSITION_TP));

      if(!result)
      {
         m_last_error_message =
            StringFormat(
               "Broker rejected SL modification: %s",
               m_trade.ResultRetcodeDescription());

         return false;
      }

      return true;
   }

   bool ModifyTakeProfit(
      ulong ticket,
      double new_tp)
   {
      m_last_error_message = "";

      if(!PositionSelectByTicket(ticket))
      {
         m_last_error_message =
            "Position not found.";

         return false;
      }

      ENUM_POSITION_TYPE position_type =
         (ENUM_POSITION_TYPE)
         PositionGetInteger(POSITION_TYPE);

      double current_tp =
         PositionGetDouble(POSITION_TP);

      if(!m_trade_protection.CanModifyTakeProfit(
            position_type,
            current_tp,
            new_tp))
      {
         m_last_error_message =
            m_trade_protection.GetLastRejectionReason();

         return false;
      }

      string symbol =
         PositionGetString(POSITION_SYMBOL);

      bool result =
         m_trade.PositionModify(
            symbol,
            PositionGetDouble(POSITION_SL),
            new_tp);

      if(!result)
      {
         m_last_error_message =
            StringFormat(
               "Broker rejected TP modification: %s",
               m_trade.ResultRetcodeDescription());

         return false;
      }

      return true;
   }

   bool ClosePosition(ulong ticket)
   {
      m_last_error_message = "";

      bool result =
         m_trade.PositionClose(ticket);

      if(!result)
      {
         m_last_error_message =
            StringFormat(
               "Broker rejected close request: %s",
               m_trade.ResultRetcodeDescription());

         return false;
      }

      if(m_cooldown != NULL)
      {
         m_cooldown.StartTradeCooldown();
      }

      return true;
   }

   bool CloseAllPositions()
   {
      bool all_closed = true;

      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);

         if(ticket == 0)
            continue;

         if(!ClosePosition(ticket))
         {
            all_closed = false;
         }
      }

      return all_closed;
   }

   bool EmergencyClose(ulong ticket)
   {
      m_last_error_message = "";

      bool result =
         m_trade.PositionClose(ticket);

      if(!result)
      {
         m_last_error_message =
            StringFormat(
               "Broker rejected emergency close: %s",
               m_trade.ResultRetcodeDescription());

         return false;
      }

      if(m_cooldown != NULL)
      {
         m_cooldown.StartEmergencyCooldown();
      }

      return true;
   }

   string GetLastErrorMessage()
   {
      return m_last_error_message;
   }

private:

   bool ValidateTradeRequest(
      double lot,
      double sl_points,
      double tp_points)
   {
      if(m_risk_manager == NULL)
      {
         m_last_error_message =
            "Risk manager not initialized.";

         return false;
      }

      if(!m_risk_manager.CanOpenTrade(
            lot,
            sl_points,
            tp_points))
      {
         m_last_error_message =
            StringFormat(
               "Risk validation failed: %s",
               m_risk_manager.GetLastRejectionReason());

         return false;
      }

      return true;
   }

   double CalculateDistancePoints(
      double price1,
      double price2)
   {
      double point =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_POINT);

      if(point <= 0.0)
         return 0.0;

      return MathAbs(price1 - price2) / point;
   }
};
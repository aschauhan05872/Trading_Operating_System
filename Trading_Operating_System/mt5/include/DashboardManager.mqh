//+------------------------------------------------------------------+
//|                                               DashboardManager.mqh |
//| Purpose: Display TOS status information on MT5 chart             |
//+------------------------------------------------------------------+
#property strict

#include "ConfigManager.mqh"
#include "DailyLimitManager.mqh"
#include "CooldownManager.mqh"
#include "LotManager.mqh"
#include "RiskManager.mqh"

class DashboardManager
{
private:
   ConfigManager*      m_config;
   DailyLimitManager*  m_daily_limit;
   CooldownManager*    m_cooldown;
   LotManager*         m_lot_manager;
   RiskManager*        m_risk_manager;

   string              m_label_names[12];
   int                 m_label_count;

public:

   DashboardManager(
      ConfigManager* config,
      DailyLimitManager* daily_limit,
      CooldownManager* cooldown,
      LotManager* lot_manager,
      RiskManager* risk_manager)
   {
      m_config       = config;
      m_daily_limit  = daily_limit;
      m_cooldown     = cooldown;
      m_lot_manager  = lot_manager;
      m_risk_manager = risk_manager;

      InitializeLabelNames();
   }

   void Initialize()
   {
      if(m_config == NULL)
         return;

      if(!m_config->IsDashboardEnabled())
         return;

      DrawDashboard();
   }

   void Update()
   {
      if(m_config == NULL)
         return;

      if(!m_config->IsDashboardEnabled())
      {
         ClearDashboard();
         return;
      }

      DrawDashboard();
   }

   void DrawDashboard()
   {
      int x = 10;
      int y = 10;
      int row_height = 18;

      CreateLabel(
         m_label_names[0],
         StringFormat("Balance: %.2f",
         AccountInfoDouble(ACCOUNT_BALANCE)),
         x,y);

      y += row_height;

      CreateLabel(
         m_label_names[1],
         StringFormat("Equity: %.2f",
         AccountInfoDouble(ACCOUNT_EQUITY)),
         x,y);

      y += row_height;

      CreateLabel(
         m_label_names[2],
         StringFormat("Peak Equity Today: %.2f",
         GetPeakEquity()),
         x,y);

      y += row_height;

      CreateLabel(
         m_label_names[3],
         StringFormat("Daily Lock Level: %.2f",
         GetDailyLockLevel()),
         x,y);

      y += row_height;

      CreateLabel(
         m_label_names[4],
         StringFormat("Remaining Daily Loss: %.2f",
         GetRemainingDailyLoss()),
         x,y);

      y += row_height;

      CreateLabel(
         m_label_names[5],
         StringFormat("Losing Trades Today: %d",
         GetLosingTradesCount()),
         x,y);

      y += row_height;

      CreateLabel(
         m_label_names[6],
         StringFormat("Cooldown Status: %s",
         GetCooldownStatus()),
         x,y);

      y += row_height;

      CreateLabel(
         m_label_names[7],
         StringFormat("Cooldown Remaining: %s",
         GetCooldownRemainingText()),
         x,y);

      y += row_height;

      CreateLabel(
         m_label_names[8],
         StringFormat("Maximum Allowed Lot: %.2f",
         GetMaximumAllowedLot()),
         x,y);

      y += row_height;

      CreateLabel(
         m_label_names[9],
         StringFormat("Risk Per Trade: %.2f",
         GetRiskPerTradeAmount()),
         x,y);

      y += row_height;

      CreateLabel(
         m_label_names[10],
         StringFormat("Open Positions: %d",
         GetOpenPositionCount()),
         x,y);

      y += row_height;

      CreateLabel(
         m_label_names[11],
         StringFormat("Trading Status: %s",
         GetTradingStatus()),
         x,y);
   }

   void ClearDashboard()
   {
      for(int i=0;i<m_label_count;i++)
      {
         ObjectDelete(
            ChartID(),
            m_label_names[i]
         );
      }
   }

   string GetTradingStatus()
   {
      if(m_daily_limit != NULL &&
         m_daily_limit->IsDailyDrawdownReached())
      {
         return "LOCKED - Daily DD";
      }

      if(m_daily_limit != NULL &&
         m_daily_limit->IsDailyLossCountReached())
      {
         return "LOCKED - Max Losses";
      }

      if(m_cooldown != NULL &&
         m_cooldown->IsCooldownActive())
      {
         return "LOCKED - Cooldown";
      }

      if(GetOpenPositionCount() > 0)
      {
         return "LOCKED - Open Position";
      }

      return "ALLOWED";
   }

private:

   void CreateLabel(
      string name,
      string text,
      int x,
      int y)
   {
      long chart_id = ChartID();

      if(ObjectFind(chart_id,name) < 0)
      {
         ObjectCreate(
            chart_id,
            name,
            OBJ_LABEL,
            0,
            0,
            0
         );
      }

      ObjectSetInteger(
         chart_id,
         name,
         OBJPROP_CORNER,
         CORNER_RIGHT_UPPER);

      ObjectSetInteger(
         chart_id,
         name,
         OBJPROP_XDISTANCE,
         x);

      ObjectSetInteger(
         chart_id,
         name,
         OBJPROP_YDISTANCE,
         y);

      ObjectSetInteger(
         chart_id,
         name,
         OBJPROP_COLOR,
         clrWhite);

      ObjectSetInteger(
         chart_id,
         name,
         OBJPROP_FONTSIZE,
         10);

      ObjectSetString(
         chart_id,
         name,
         OBJPROP_TEXT,
         text);
   }

   void InitializeLabelNames()
   {
      m_label_count = 12;

      m_label_names[0]  = "TOS_BALANCE";
      m_label_names[1]  = "TOS_EQUITY";
      m_label_names[2]  = "TOS_PEAK";
      m_label_names[3]  = "TOS_LOCK";
      m_label_names[4]  = "TOS_REMAINING";
      m_label_names[5]  = "TOS_LOSSES";
      m_label_names[6]  = "TOS_CD_STATUS";
      m_label_names[7]  = "TOS_CD_TIME";
      m_label_names[8]  = "TOS_MAX_LOT";
      m_label_names[9]  = "TOS_RISK";
      m_label_names[10] = "TOS_OPEN";
      m_label_names[11] = "TOS_STATUS";
   }

   double GetPeakEquity()
   {
      return (m_daily_limit != NULL)
         ? m_daily_limit->GetPeakEquityToday()
         : 0.0;
   }

   double GetDailyLockLevel()
   {
      return (m_daily_limit != NULL)
         ? m_daily_limit->GetDailyLockLevel()
         : 0.0;
   }

   double GetRemainingDailyLoss()
   {
      return (m_daily_limit != NULL)
         ? m_daily_limit->GetRemainingDailyLoss()
         : 0.0;
   }

   int GetLosingTradesCount()
   {
      return (m_daily_limit != NULL)
         ? m_daily_limit->GetDailyLossCount()
         : 0;
   }

   string GetCooldownStatus()
   {
      if(m_cooldown == NULL)
         return "Unknown";

      return m_cooldown->IsCooldownActive()
         ? "ACTIVE"
         : "CLEAR";
   }

   string GetCooldownRemainingText()
   {
      if(m_cooldown == NULL)
         return "00:00";

      int seconds =
         m_cooldown->GetRemainingCooldownSeconds();

      int minutes = seconds / 60;
      int remain  = seconds % 60;

      return StringFormat(
         "%02d:%02d",
         minutes,
         remain
      );
   }

   double GetMaximumAllowedLot()
   {
      return (m_lot_manager != NULL)
         ? m_lot_manager->GetMaximumAllowedLot()
         : 0.0;
   }

   double GetRiskPerTradeAmount()
   {
      return (m_lot_manager != NULL)
         ? m_lot_manager->GetCurrentRiskAmount()
         : 0.0;
   }

   int GetOpenPositionCount()
   {
      if(m_lot_manager == NULL)
         return PositionsTotal();

      string symbol =
         m_lot_manager->GetSymbol();

      int count = 0;

      for(int i=0;i<PositionsTotal();i++)
      {
         ulong ticket =
            PositionGetTicket(i);

         if(ticket == 0)
            continue;

         if(!PositionSelectByTicket(ticket))
            continue;

         if(PositionGetString(POSITION_SYMBOL)
            == symbol)
         {
            count++;
         }
      }

      return count;
   }
};
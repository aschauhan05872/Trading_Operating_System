//+------------------------------------------------------------------+
//|                                                       LotManager.mqh |
//| Purpose: Calculate risk-based lot sizes and enforce account caps. |
//+------------------------------------------------------------------+
#property strict

#include "ConfigManager.mqh"

class LotManager
{
private:
   double            m_min_lot;
   double            m_lot_step;
   double            m_max_lot;
   string            m_symbol;
   ConfigManager* m_config;

public:
   LotManager(cConfigManager* config, const string symbol)
   {
      m_config = config;
      m_symbol = symbol;
      m_min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      m_lot_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      m_max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   }

   double GetCurrentRiskAmount()
   {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      return equity * m_config->GetRiskPerTradePercent() / 100.0;
   }

   double GetMaximumAllowedLot()
   {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double cap = 0.01;

      if(equity <= 100.0)
         cap = 0.01;
      else if(equity <= 200.0)
         cap = 0.02;
      else if(equity <= 300.0)
         cap = 0.03;
      else if(equity <= 400.0)
         cap = 0.04;
      else
      {
         int account_bucket = (int)MathCeil(equity / 100.0);
         cap = account_bucket * 0.01;
      }

      return MathMin(cap, m_max_lot);
   }

   double CalculateRiskBasedLot(const ConfigManager &config, double stop_loss_points)
   {
      if(stop_loss_points <= 0.0)
         return 0.0;

      double risk_amount = GetCurrentRiskAmount(config);
      double tick_value = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_VALUE);
      double tick_size = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);

      if(tick_value <= 0.0 || tick_size <= 0.0)
         return 0.0;

      double value_per_point = tick_value / tick_size;
      double lots = risk_amount / (stop_loss_points * value_per_point);
      return NormalizeLot(lots);
   }

   double GetFinalAllowedLot(const ConfigManager &config, double stop_loss_points)
   {
      double risk_lot = CalculateRiskBasedLot(config, stop_loss_points);
      double max_allowed = GetMaximumAllowedLot();
      return MathMin(risk_lot, max_allowed);
   }

   bool CanTradeLot(double requested_lot)
   {
      if(requested_lot <= 0.0)
         return false;

      requested_lot = NormalizeLot(requested_lot);
      double max_allowed = GetMaximumAllowedLot();

      return (requested_lot <= max_allowed) && (requested_lot >= m_min_lot);
   }

private:
   double NormalizeLot(double lot)
   {
      if(lot < m_min_lot)
         return 0.0;

      double steps = MathFloor((lot - m_min_lot) / m_lot_step + 0.5);
      double normalized = m_min_lot + steps * m_lot_step;
      normalized = MathMax(normalized, m_min_lot);
      return MathMin(normalized, m_max_lot);
   }
};

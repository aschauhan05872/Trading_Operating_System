//+------------------------------------------------------------------+
//|                                       TradingOperatingSystem.mq5 |
//| Purpose: Main Expert Advisor for Trading Operating System (TOS)  |
//+------------------------------------------------------------------+
#property strict

#include "ConfigManager.mqh"
#include "DailyLimitManager.mqh"
#include "CooldownManager.mqh"
#include "LotManager.mqh"
#include "RiskManager.mqh"
#include "TradeProtectionManager.mqh"
#include "TradeManager.mqh"
#include "DashboardManager.mqh"

//====================================================================
// Global Managers
//====================================================================

ConfigManager*             g_config            = NULL;
DailyLimitManager*         g_dailyLimit        = NULL;
CooldownManager*           g_cooldown          = NULL;
LotManager*                g_lotManager        = NULL;
RiskManager*               g_riskManager       = NULL;
TradeProtectionManager*    g_tradeProtection   = NULL;
TradeManager*              g_tradeManager      = NULL;
DashboardManager*          g_dashboard         = NULL;

//+------------------------------------------------------------------+
//| Expert Initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("Initializing Trading Operating System Phase 1...");

   //==============================================================
   // Create Managers
   //==============================================================

   g_config = new ConfigManager();

   if(g_config == NULL)
      return INIT_FAILED;

   g_dailyLimit = new DailyLimitManager(g_config);

   if(g_dailyLimit == NULL)
      return INIT_FAILED;

   g_cooldown = new CooldownManager(g_config);

   if(g_cooldown == NULL)
      return INIT_FAILED;

   g_lotManager = new LotManager(
      g_config,
      _Symbol
   );

   if(g_lotManager == NULL)
      return INIT_FAILED;

   g_riskManager = new RiskManager(
      g_config,
      g_dailyLimit,
      g_cooldown,
      g_lotManager
   );

   if(g_riskManager == NULL)
      return INIT_FAILED;

   g_tradeProtection = new TradeProtectionManager(
      g_config
   );

   if(g_tradeProtection == NULL)
      return INIT_FAILED;

   g_tradeManager = new TradeManager(
      g_config,
      g_riskManager,
      g_tradeProtection,
      g_cooldown,
      g_lotManager
   );

   if(g_tradeManager == NULL)
      return INIT_FAILED;

   g_dashboard = new DashboardManager(
      g_config,
      g_dailyLimit,
      g_cooldown,
      g_lotManager,
      g_riskManager
   );

   if(g_dashboard == NULL)
      return INIT_FAILED;

   //==============================================================
   // Initialize Managers
   //==============================================================

   g_dailyLimit->Initialize();
   g_cooldown->Initialize();
   g_riskManager->Initialize();
   g_tradeProtection->Initialize();
   g_tradeManager->Initialize();
   g_dashboard->Initialize();

   Print("TOS Phase 1 initialized successfully.");

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert Tick                                                      |
//+------------------------------------------------------------------+
void OnTick()
{
   if(g_dailyLimit != NULL)
      g_dailyLimit->Update();

   if(g_cooldown != NULL)
      g_cooldown->Update();

   if(g_dashboard != NULL)
      g_dashboard->Update();
}

//+------------------------------------------------------------------+
//| Expert Deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("Shutting down Trading Operating System...");

   if(g_dashboard != NULL)
   {
      g_dashboard->ClearDashboard();
      delete g_dashboard;
      g_dashboard = NULL;
   }

   if(g_tradeManager != NULL)
   {
      delete g_tradeManager;
      g_tradeManager = NULL;
   }

   if(g_tradeProtection != NULL)
   {
      delete g_tradeProtection;
      g_tradeProtection = NULL;
   }

   if(g_riskManager != NULL)
   {
      delete g_riskManager;
      g_riskManager = NULL;
   }

   if(g_lotManager != NULL)
   {
      delete g_lotManager;
      g_lotManager = NULL;
   }

   if(g_cooldown != NULL)
   {
      delete g_cooldown;
      g_cooldown = NULL;
   }

   if(g_dailyLimit != NULL)
   {
      delete g_dailyLimit;
      g_dailyLimit = NULL;
   }

   if(g_config != NULL)
   {
      delete g_config;
      g_config = NULL;
   }

   Print("TOS shutdown completed.");
}
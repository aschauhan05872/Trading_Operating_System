//+------------------------------------------------------------------+
//|                                                   CooldownManager.mqh |
//| Purpose: Manage normal and emergency cooldown periods for Phase 1|
//|          account protection and anti-revenge trading.           |
//+------------------------------------------------------------------+
#property strict

#include "ConfigManager.mqh"

class CooldownManager
{
private:
   datetime         m_normal_cooldown_end;
   datetime         m_emergency_cooldown_end;
   ConfigManager* m_config;

public:
   CooldownManager(ConfigManager* config)
   {
      m_config = config;
      Initialize();
   }

   void Initialize()
   {
      m_normal_cooldown_end = 0;
      m_emergency_cooldown_end = 0;
   }

   void StartTradeCooldown()
   {
      datetime now = TimeCurrent();
      int cooldown_minutes = m_config.GetCooldownMinutes();
      m_normal_cooldown_end = now + cooldown_minutes * 60;
   }

   void StartEmergencyCooldown()
   {
      datetime now = TimeCurrent();
      int lock_minutes = m_config.GetEmergencyLockDurationMinutes();
      m_emergency_cooldown_end = now + lock_minutes * 60;
   }

   bool IsCooldownActive()
   {
      datetime now = TimeCurrent();
      return (m_emergency_cooldown_end > now) || (m_normal_cooldown_end > now);
   }

   int GetRemainingCooldownSeconds()
   {
      datetime now = TimeCurrent();
      int normal_remaining = 0;
      int emergency_remaining = 0;

      if(m_normal_cooldown_end > now)
         normal_remaining = (int)(m_normal_cooldown_end - now);

      if(m_emergency_cooldown_end > now)
         emergency_remaining = (int)(m_emergency_cooldown_end - now);

      return MathMax(normal_remaining, emergency_remaining);
   }

   datetime GetCooldownEndTime()
   {
      return MathMax(m_normal_cooldown_end, m_emergency_cooldown_end);
   }

   bool CanTrade()
   {
      return !IsCooldownActive();
   }

   void Update()
   {
      datetime now = TimeCurrent();

      if(m_normal_cooldown_end <= now)
         m_normal_cooldown_end = 0;

      if(m_emergency_cooldown_end <= now)
         m_emergency_cooldown_end = 0;
   }
};

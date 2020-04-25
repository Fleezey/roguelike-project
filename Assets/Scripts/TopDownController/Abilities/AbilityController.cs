using System;
using UnityEngine;


namespace FGSX.Abilities
{
    public class AbilityController : MonoBehaviour
    {
        public Action<Ability> m_OnAbilityReady;
        public Action<Ability, float> m_OnAbilityCooldownUpdate;

        public string m_AbilityButtonName = "";
        
        [SerializeField] private Ability m_Ability;
        [SerializeField] private GameObject m_WeaponHolder;
        private float m_CooldownDuration;
        private float m_NextReadyTime;
        private float m_CooldownTimeLeft;
        private bool m_IsReady;
        private float m_InputAxis = 0f;
        private float m_LastInputAxis = 0f;


        private void Start()
        {
            Initialize(m_Ability, m_WeaponHolder);
        }

        private void Update()
        {
            m_InputAxis = Math.Abs(Input.GetAxisRaw(m_AbilityButtonName));

            bool cooldownCompleted = (Time.time > m_NextReadyTime);
            if (cooldownCompleted)
            {
                if (!m_IsReady)
                {
                    AbilityReady();
                }

                if (m_Ability.m_IsContinuous && (Input.GetButton(m_AbilityButtonName) || IsHoldingTrigger()) || (Input.GetButtonDown(m_AbilityButtonName) || GetTriggerDown()))
                {
                    OnAbilityTriggered();
                }
            }
            else
            {
                Cooldown();
            }

            m_LastInputAxis = m_InputAxis;
        }


        public void Initialize(Ability ability, GameObject weaponHolder)
        {
            m_Ability = ability;
            m_CooldownDuration = ability.m_Cooldown;
            ability.Initialize(weaponHolder);
            AbilityReady();
        }


        private void AbilityReady()
        {
            m_IsReady = true;

            if (m_OnAbilityReady != null)
            {
                m_OnAbilityReady(m_Ability);
            }
        }

        private void Cooldown()
        {
            m_CooldownTimeLeft -= Time.deltaTime;

            if (m_OnAbilityCooldownUpdate != null)
            {
                m_OnAbilityCooldownUpdate(m_Ability, m_CooldownTimeLeft);
            }
        }

        private void OnAbilityTriggered()
        {
            m_IsReady = false;

            m_NextReadyTime = m_CooldownDuration + Time.time;
            m_CooldownTimeLeft = m_CooldownDuration;

            m_Ability.TriggerAbility();
        }


        private bool GetTriggerDown()
        {
            return m_LastInputAxis == 0f && IsHoldingTrigger();
        }

        private bool IsHoldingTrigger()
        {
            return m_InputAxis == 1f;
        }
    }
}


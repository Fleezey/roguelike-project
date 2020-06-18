using FGSX.TopDownController.Entity;
using System;
using UnityEngine;
using UnityEngine.UI;


namespace FGSX.UI
{
    [RequireComponent(typeof (ProgressBar))]
    public class PlayerHealthBar : MonoBehaviour
    {
        [Header("Health Thresholds")]
        [SerializeField] private HealthThreshold m_HighHealth;
        [SerializeField] private HealthThreshold m_MediumHealth;
        [SerializeField] private HealthThreshold m_LowHealth;

        [Header("References")]
        [SerializeField] private Living m_Entity;

        private ProgressBar m_ProgressBar;


        private void Awake()
        {
            m_ProgressBar = GetComponent<ProgressBar>();
        }
        
        private void Start()
        {
            UpdateBar();

            m_ProgressBar.OnValuesValidated += UpdateBar;
            m_Entity.OnHealthChange += UpdateBar;
            m_Entity.OnMaxHealthChange += UpdateBar;
        }

        private void OnValidate()
        {
            UpdateBar();
        }


        private void UpdateBar()
        {
            if (m_ProgressBar == null) return;

            if (m_ProgressBar.MinimumValue < 0f)
            {
                m_ProgressBar.MinimumValue = 0f;
            }

            m_ProgressBar.CurrentValue = m_Entity.Health;
            m_ProgressBar.MaximumValue = m_Entity.MaxHealth;

            float percentage = m_Entity.Health / m_Entity.MaxHealth;
            if (percentage <= m_LowHealth.m_Percentage)
            {
                m_ProgressBar.FillColor = m_LowHealth.m_Color;
            }
            else if (percentage <= m_MediumHealth.m_Percentage)
            {
                m_ProgressBar.FillColor = m_MediumHealth.m_Color;
            }
            else
            {
                m_ProgressBar.FillColor = m_HighHealth.m_Color;
            }
        }


        [Serializable]
        private class HealthThreshold
        {
            [SerializeField][Range(0f, 1f)] public float m_Percentage;
            [SerializeField] public Color m_Color;
        }
    }
}

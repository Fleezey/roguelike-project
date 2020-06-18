using System;
using UnityEngine;
using UnityEngine.UI;


namespace FGSX.UI
{
    public class ProgressBar : MonoBehaviour
    {
        [Header("Progress Bar Properties")]
        [SerializeField] private float m_Minimum;
        [SerializeField] private float m_Maximum;
        [SerializeField] private float m_Current;
        [SerializeField] private Color m_Color;

        [Header("References")]
        [SerializeField] private Image m_Mask;
        [SerializeField] private Image m_Fill;


        public event Action OnValuesValidated;

        public float MinimumValue
        {
            get => m_Minimum;
            set
            {
                m_Minimum = value;
                UpdateBar();
            }
        }

        public float MaximumValue
        {
            get => m_Maximum;
            set
            {
                m_Maximum = value;
                UpdateBar();
            }
        }

        public float CurrentValue
        {
            get => m_Current;
            set
            {
                m_Current = value;
                UpdateBar();
            }
        }

        public Color FillColor
        {
            get => m_Color;
            set
            {
                m_Color = value;
                UpdateBar();
            }
        }


        private void Start()
        {
            UpdateBar();
        }


        private void UpdateBar()
        {
            float currentOffset = m_Current - m_Minimum;
            float maximumOffset = m_Maximum - m_Minimum;
            float fillAmount = currentOffset / maximumOffset;
            m_Mask.fillAmount = fillAmount;
            m_Fill.color = m_Color;
        }


        private void OnValidate()
        {
            if (m_Current > m_Maximum)
            {
                m_Current = m_Maximum;
            }

            UpdateBar();
            if (OnValuesValidated != null)
            {
                OnValuesValidated();
            }
        }
    }
}


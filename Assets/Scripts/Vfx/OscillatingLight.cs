using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Light))]
public class OscillatingLight : MonoBehaviour
{
    [SerializeField] private Vector2 m_LightIntensityRange = default;
    [SerializeField] private Vector2 m_LightRangeRange = default;
    [SerializeField] private float m_Tick = default;
    [SerializeField] private float m_TimeTick = default;

    private Light m_Light;
    private float m_Time;
    private float m_TimeLoop;

    private void Awake()
    {
        if(GetComponent<Light>() != null)
        {
            m_Light = GetComponent<Light>();
        }
        m_TimeLoop = Mathf.PI * 2.0f;
    }

    private void Start()
    {
        StartCoroutine(LightUpdate());
    }

    private IEnumerator LightUpdate()
    {
        while(true)
        {
            if(m_Light != null)
            {
                float minMaxDistance = (m_LightIntensityRange.y - m_LightIntensityRange.x) / 2.0f;
                float minMaxRange = (m_LightRangeRange.y - m_LightRangeRange.x) / 2.0f;
                m_Light.intensity = Mathf.Sin(m_Time) * minMaxDistance + m_LightIntensityRange.x + minMaxDistance;
                m_Light.range = Mathf.Sin(m_Time) * minMaxRange + m_LightRangeRange.x + minMaxRange;
            }
            if(m_Time >= m_TimeLoop)
            {
                m_Time = 0.0f;
            }
            else
            {
                m_Time += m_Tick;
            }

            yield return new WaitForSeconds(m_TimeTick);
        }
    }
}

using UnityEngine;


public class TimeToLive : MonoBehaviour
{
    public float m_TimeAlive;
    private float m_TimeToKill;


    private void Start()
    {
        m_TimeToKill = Time.time + m_TimeAlive;
    }
    
    private void Update()
    {
        if (Time.time >= m_TimeToKill)
        {
            Destroy(gameObject);
        }
    }
}

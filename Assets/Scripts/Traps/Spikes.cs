using System.Collections;
using UnityEngine;


namespace FGSX.Traps
{
    public class Spikes : MonoBehaviour
    {
        [SerializeField] private int m_MaterialIndex = 0;
        [SerializeField] private string m_MovePropertyName = "_LinearMove";

        [SerializeField] private float m_ActivationTime = 0.175f;
        [SerializeField] private float m_ThrustDelay = 0.5f;
        [SerializeField] private float m_ThrustTime = 0.225f;
        [SerializeField] private float m_DeactivationDelay = 1f;
        [SerializeField] private float m_DeactivationTime = 0.375f;

        [SerializeField] private float m_ActivateMove = 0.5f;

        private MeshRenderer m_MeshRenderer;
        private bool m_IsActivating = false;

        // TODO: Remove that property
        [SerializeField] private string m_DebugKey = "q";
        

        private void Awake()
        {
            m_MeshRenderer = GetComponent<MeshRenderer>();
            m_MeshRenderer.materials[m_MaterialIndex] = new Material(m_MeshRenderer.materials[m_MaterialIndex]);
            m_MeshRenderer.materials[m_MaterialIndex].SetFloat(m_MovePropertyName, 0f);
        }

        private void Update()
        {
            if (Input.GetKeyDown(m_DebugKey) && !m_IsActivating)
            {
                m_IsActivating = true;
                StartCoroutine(Activate());
            }
        }


        private IEnumerator Activate()
        {
            float elapsedTime = 0f;
            while (elapsedTime < m_ActivationTime)
            {
                float value = Mathf.Lerp(0f, m_ActivateMove, elapsedTime / m_ActivationTime);
                m_MeshRenderer.materials[m_MaterialIndex].SetFloat(m_MovePropertyName, value);
                elapsedTime += Time.deltaTime;
                yield return null;
            }

            yield return new WaitForSeconds(m_ThrustDelay);

            elapsedTime = 0f;
            while (elapsedTime < m_ThrustTime)
            {
                float value = Mathf.Lerp(m_ActivateMove, 1f, elapsedTime / m_ActivationTime);
                m_MeshRenderer.materials[m_MaterialIndex].SetFloat(m_MovePropertyName, value);
                elapsedTime += Time.deltaTime;
                yield return null;
            }

            yield return new WaitForSeconds(m_DeactivationDelay);

            elapsedTime = 0f;
            while (elapsedTime < m_DeactivationTime)
            {
                float value = Mathf.Lerp(1f, 0f, elapsedTime / m_DeactivationTime);
                m_MeshRenderer.materials[m_MaterialIndex].SetFloat(m_MovePropertyName, value);
                elapsedTime += Time.deltaTime;
                yield return null;
            }

            m_IsActivating = false;
        }
    }
}

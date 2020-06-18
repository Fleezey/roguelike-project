using UnityEngine;


namespace FGSX.Traps.Spikes
{
    public class Spikes : StateMachine
    {
        public float Damage => m_Damage;
        public bool AlwaysActive => m_AlwaysActive;

        [SerializeField] private float m_Damage = 1f;
        [SerializeField] private bool m_AlwaysActive = false;

        [Header("Shader Properties")]
        [SerializeField] private int m_SpikeMaterialIndex;
        [SerializeField] private string m_SpikeShaderName = "ENV/Basic Vertex Color Linear Move";
        [SerializeField] private string m_SpikeMoveProperty = "_LinearMove";

        private Material m_SpikeMaterial;
        private MeshRenderer m_MeshRenderer;


        private void Awake()
        {
            m_MeshRenderer = gameObject.GetComponent<MeshRenderer>();
            m_MeshRenderer.materials[m_SpikeMaterialIndex] = new Material(Shader.Find(m_SpikeShaderName));;
            m_SpikeMaterial = m_MeshRenderer.materials[m_SpikeMaterialIndex];
        }

        private void Start()
        {
            if (m_AlwaysActive)
            {
                SetState(new Activated(this));
            }
            else
            {
                SetState(new Idle(this));
            }
        }

        private void OnTriggerStay(Collider collider)
        {
            StartCoroutine(m_State.ProcessCollision(collider));
        }


        public float GetSpikeHeight() => m_SpikeMaterial.GetFloat(m_SpikeMoveProperty);

        public void SetSpikeHeight(float value)
        {
            m_SpikeMaterial.SetFloat(m_SpikeMoveProperty, value);
        }
    }
}

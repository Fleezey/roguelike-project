using UnityEngine;


namespace FGSX.Abilities
{
    public class DestroyOnCollision : MonoBehaviour
    {
        public LayerMask m_Layers;

        private void OnTriggerEnter(Collider other) {
            if (((1 << other.gameObject.layer) & m_Layers) != 0)
            {
                Destroy(gameObject);
            }
        }
    }
}

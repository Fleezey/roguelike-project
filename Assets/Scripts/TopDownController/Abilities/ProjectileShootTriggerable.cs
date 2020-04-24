using UnityEngine;


namespace FGSX.Abilities
{
    public class ProjectileShootTriggerable : MonoBehaviour
    {
        [HideInInspector] public Rigidbody m_Projectile;
        public Transform m_ProjectileSpawn;
        [HideInInspector] public float m_ProjectileForce = 250f;


        public void Launch()
        {
            Rigidbody clonedProjectile = Instantiate(m_Projectile, m_ProjectileSpawn.position, transform.rotation) as Rigidbody;
            clonedProjectile.AddForce(m_ProjectileSpawn.transform.forward * m_ProjectileForce);
        }
    }
}

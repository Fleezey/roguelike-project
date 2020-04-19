/**
 * TODO:
 *   - Implement a time to live
 *   - Collision detection
 */

using UnityEngine;


namespace FGSX.Abilities
{
    [CreateAssetMenu(menuName = "Abilities/Projectile Ability")]
    public class ProjectileAbility : Ability
    {
        public float m_ProjectileForce = 500f;
        public Rigidbody m_Projectile;

        private ProjectileShootTriggerable m_Launcher;


        public override void Initialize(GameObject gameObject)
        {
            m_Launcher = gameObject.GetComponent<ProjectileShootTriggerable>();
            m_Launcher.m_ProjectileForce = m_ProjectileForce;
            m_Launcher.m_Projectile = m_Projectile;
        }

        public override void TriggerAbility()
        {
            m_Launcher.Launch();
        }
    }
}

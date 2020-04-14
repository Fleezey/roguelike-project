using System;
using UnityEngine;


namespace FGSX.TopDownController
{
    public class LivingEntity : MonoBehaviour
    {
        public float Health { get; protected set; }
        public float MaxHealth { get; protected set; }

        public event Action m_OnDeath;

        protected bool m_IsDead;


        protected virtual void Start()
        {
            Health = MaxHealth;
        }


        public virtual void TakeHit(float damage, Vector3 hitPoint, Vector3 hitDirection)
        {
            TakeDamage(damage);
        }

        public virtual void TakeDamage(float damage)
        {
            Health -= damage;

            if (Health <= 0 && !m_IsDead)
            {
                Die();
            }
        }

        [ContextMenu("Self Destruct")]
        public virtual void Die()
        {
            m_IsDead = true;

            if (m_OnDeath != null)
            {
                m_OnDeath();
            }

            Destroy(gameObject);
        }
    }
}

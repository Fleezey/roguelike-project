using System;
using System.Collections;
using UnityEngine;


namespace FGSX.TopDownController.Entity
{
    public abstract class Living : Entity
    {
        public float Health { get; protected set; }
        public float MaxHealth { get; protected set; }
        public float RecoveryTime { get; protected set; }
        public bool IsRecovering { get; protected set; }

        public event Action m_OnDeath;

        protected bool m_IsDead;


        protected override void Start()
        {
            base.Start();
            Health = MaxHealth;
            RecoveryTime = 0f;
        }


        public virtual void TakeHit(float damage, Vector3 hitPoint, Vector3 hitDirection)
        {
            TakeDamage(damage);
        }

        public virtual void TakeDamage(float damage)
        {
            if (IsRecovering)
            {
                return;
            }

            Health -= damage;

            if (Health <= 0 && !m_IsDead)
            {
                Die();
            }

            StartCoroutine(Recovery());
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


        private IEnumerator Recovery()
        {
            IsRecovering = true;
            float elapsed = 0f;
            
            while (elapsed < RecoveryTime)
            {
                elapsed += Time.deltaTime;
                yield return null;
            }

            IsRecovering = false;
            yield break;
        }
    }
}

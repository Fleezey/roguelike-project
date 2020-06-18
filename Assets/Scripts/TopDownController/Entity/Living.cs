using System;
using System.Collections;
using UnityEngine;


namespace FGSX.TopDownController.Entity
{
    public abstract class Living : Entity
    {
        public event Action m_OnDeath;
        public event Action OnHealthChange;
        public event Action OnMaxHealthChange;

        public float Health
        {
            get => m_Health;
            protected set
            {
                Debug.Log("Change health");
                m_Health = value;
                if (OnHealthChange != null)
                {
                    Debug.Log("Change health action");
                    OnHealthChange();
                }
            }
        }

        public float MaxHealth
        {
            get => m_MaxHealth;
            protected set
            {
                m_MaxHealth = value;
                if (OnMaxHealthChange != null)
                {
                    OnMaxHealthChange();
                }
            }
        }

        public float RecoveryTime { get; protected set; }
        public bool IsRecovering { get; protected set; }

        protected bool m_IsDead;
        private float m_Health;
        private float m_MaxHealth;


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
            Debug.Log("Take damage");

            if (Health <= 0 && !m_IsDead)
            {
                Die();
            }
            else
            {
                StartCoroutine(Recovery());
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

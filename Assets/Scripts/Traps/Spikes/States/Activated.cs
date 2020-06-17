using FGSX.TopDownController.Entity;

using System.Collections;
using UnityEngine;


namespace FGSX.Traps.Spikes
{
    public class Activated : State
    {
        public Activated(Spikes spikes) : base(spikes)
        {
        }

        public override IEnumerator Start()
        {
            m_Spikes.StartCoroutine(AnimateSpikes());
            yield return new WaitForSeconds(1f);

            m_Spikes.SetState(new Cooldown(m_Spikes));
            yield break;
        }

        public override IEnumerator ProcessCollision(Collider collider)
        {
            Living livingEntity = collider.gameObject.GetComponentInChildren<Living>();
            if (livingEntity) {
                livingEntity.TakeDamage(m_Spikes.Damage);
                yield break;
            }
        }

        private IEnumerator AnimateSpikes()
        {
            float duration = 0.125f;
            float elapsedTime = 0f;
            float initialHeight = m_Spikes.GetSpikeHeight();

            while (elapsedTime < duration)
            {
                float height = Mathf.Lerp(initialHeight, 1f, elapsedTime / duration);
                m_Spikes.SetSpikeHeight(height);
                elapsedTime += Time.deltaTime;
                yield return null;
            }

            yield break;
        }
    }
}

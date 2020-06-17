using System.Collections;
using UnityEngine;


namespace FGSX.Traps.Spikes
{
    public class Cooldown : State
    {
        public Cooldown(Spikes spikes) : base(spikes)
        {
        }

        public override IEnumerator Start()
        {
            m_Spikes.StartCoroutine(AnimateSpikes());
            yield return new WaitForSeconds(2f);

            m_Spikes.SetState(new Idle(m_Spikes));
            yield break;
        }

        private IEnumerator AnimateSpikes()
        {
            float duration = 2f;
            float elapsedTime = 0f;
            float initialHeight = m_Spikes.GetSpikeHeight();

            while (elapsedTime < duration)
            {
                float height = Mathf.Lerp(initialHeight, 0f, elapsedTime / duration);
                m_Spikes.SetSpikeHeight(height);
                elapsedTime += Time.deltaTime;
                yield return null;
            }

            yield break;
        }
    }
}


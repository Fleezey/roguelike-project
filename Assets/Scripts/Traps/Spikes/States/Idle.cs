using FGSX.TopDownController.Entity;

using System.Collections;
using UnityEngine;


namespace FGSX.Traps.Spikes
{
    public class Idle : State
    {
        public Idle(Spikes spikes) : base(spikes)
        {
        }

        public override IEnumerator Start()
        {
            m_Spikes.SetSpikeHeight(0f);
            yield break;
        }

        public override IEnumerator ProcessCollision(Collider collider)
        {
            Player player = collider.gameObject.GetComponentInChildren<Player>();
            if (player) {
                m_Spikes.SetState(new Ready(m_Spikes));
                yield break;
            }

            yield break;
        }
    }
}


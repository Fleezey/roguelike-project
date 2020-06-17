using System.Collections;
using UnityEngine;


namespace FGSX.Traps.Spikes
{
    public class Ready : State
    {
        public Ready(Spikes spikes) : base(spikes)
        { 
        }

        public override IEnumerator Start()
        {
            m_Spikes.SetSpikeHeight(0.7f);
            yield return new WaitForSeconds(0.75f);

            m_Spikes.SetState(new Activated(m_Spikes));
            yield break;
        }
    }
}

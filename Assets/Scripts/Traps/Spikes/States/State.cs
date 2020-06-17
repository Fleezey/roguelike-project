using System.Collections;
using UnityEngine;


namespace FGSX.Traps.Spikes
{
    public abstract class State
    {
        protected Spikes m_Spikes;


        public State(Spikes spikes)
        {
            m_Spikes = spikes;
        }

        public virtual IEnumerator Start()
        {
            yield break;
        }

        public virtual IEnumerator ProcessCollision(Collider collider)
        {
            yield break;
        }
    }
}


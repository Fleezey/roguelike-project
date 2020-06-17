using UnityEngine;


namespace FGSX.Traps.Spikes
{
    public abstract class StateMachine : MonoBehaviour
    {
        protected State m_State;


        public void SetState(State state)
        {
            m_State = state;
            StartCoroutine(m_State.Start());
        }
    }
}

using UnityEngine;


namespace FGSX.TopDownController.Entity.State
{
    public abstract class StateMachine : MonoBehaviour
    {
        protected State m_State;


        public void SetState(State state)
        {
            m_State = state;
            m_State.Start();
        }
    }
}

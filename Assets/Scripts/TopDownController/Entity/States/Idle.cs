using UnityEngine;


namespace FGSX.TopDownController.Entity.State
{
    public class Idle : State
    {
        public Idle(Entity entity) : base(entity)
        {
        }

        public override void ProcessInput()
        {
            Vector3 moveInput = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical"));
            if (moveInput.magnitude > 0f)
            {
                m_Entity.SetState(new Running(m_Entity));
            }
        }
    }
}


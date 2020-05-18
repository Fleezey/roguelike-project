using UnityEngine;


namespace FGSX.TopDownController.Entity.State
{
    public class Running : State
    {
        public Running(Entity entity) : base(entity)
        {
        }

        public override void ProcessInput()
        {
            ProcessMovementInput();
        }

        private void ProcessMovementInput()
        {
            Vector3 moveInput = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical"));
            if (moveInput.magnitude <= 0f)
            {
                m_Entity.SetState(new Idle(m_Entity));
                return;
            }

            if (Input.GetButtonDown("Roll"))
            {
                m_Entity.SetState(new Rolling(m_Entity, moveInput));
                return;
            }

            m_Entity.Controller.Move(moveInput);
        }
    }
}


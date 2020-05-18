using UnityEngine;


namespace FGSX.TopDownController.Entity.State
{
    public class Rolling : State
    {
        private Vector3 m_RollDirection;


        public Rolling(Entity entity, Vector3 direction) : base(entity)
        {
            m_RollDirection = direction;
        }


        public override void Start()
        {
            base.Start();

            Player player = m_Entity as Player;
            player.Animator.SetTrigger("Roll");
            Debug.Log("Rolling!");
            player.PlayerAnimations.m_OnRollEnd += onRollEnd;
        }

        public override void ProcessInput()
        {
            m_Entity.Controller.Roll(m_RollDirection);
        }

        private void onRollEnd()
        {
            m_Entity.SetState(new Running(m_Entity));
        }
    }
}


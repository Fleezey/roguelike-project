using FGSX.TopDownController.Entity.State;
using UnityEngine;


namespace FGSX.TopDownController.Entity
{
    [RequireComponent(typeof (EntityController))]
    public class Entity : StateMachine
    {
        public EntityController Controller { get; protected set; }


        protected virtual void Awake()
        {
            Controller = GetComponent<EntityController>();
        }

        protected virtual void Start()
        {
            SetState(new Idle(this));
        }

        protected virtual void Update()
        {
            m_State.ProcessInput();
        }
    }
}
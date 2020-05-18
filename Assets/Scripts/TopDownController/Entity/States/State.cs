using FGSX.TopDownController.Entity;


namespace FGSX.TopDownController.Entity.State
{
    public abstract class State
    {
        protected Entity m_Entity;


        public State(Entity entity)
        {
            m_Entity = entity;
        }


        public virtual void Start()
        {
            ProcessInput();
        }

        public abstract void ProcessInput();
    }
}


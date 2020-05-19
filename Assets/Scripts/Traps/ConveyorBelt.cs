using FGSX.TopDownController.Entity;
using UnityEngine;


namespace FGSX.Traps
{
    public class ConveyorBelt : MonoBehaviour
    {
        [SerializeField] private float m_Speed;


        private void OnTriggerEnter(Collider other)
        {
            EntityController entityController = other.GetComponent<EntityController>();
            if (entityController)
            {
                entityController.AddAdditionalMovementVelocity(gameObject, transform.forward * m_Speed);
            }
        }

        private void OnTriggerExit(Collider other)
        {
            EntityController entityController = other.GetComponent<EntityController>();
            if (entityController)
            {
                entityController.RemoveAdditionalMovementVelocity(gameObject);
            }
        }
    }
}

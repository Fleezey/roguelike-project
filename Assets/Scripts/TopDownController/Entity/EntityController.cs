using UnityEngine;


namespace FGSX.TopDownController.Entity
{
    [RequireComponent(typeof (CharacterController))]
    public class EntityController : MonoBehaviour
    {
        [SerializeField] private float m_MoveSpeed = 8f;
        [SerializeField] private float m_GravityScale = 1f;

        private CharacterController m_CharacterController;


        private void Awake()
        {
            m_CharacterController = GetComponent<CharacterController>();
        }


        public void Move(Vector3 inputDirection)
        {
            // Prevent from moving faster diagonally
            Vector3 moveDirection = (inputDirection.sqrMagnitude > 1f) ? inputDirection.normalized : inputDirection;

            Vector3 moveVelocity = moveDirection * m_MoveSpeed;
            Vector3 gravityVelocity = Physics.gravity * m_GravityScale;

            Vector3 targetVelocity = moveVelocity + gravityVelocity;
            m_CharacterController.Move(targetVelocity * Time.deltaTime);
        }

        public void LookAt(Vector3 lookPoint)
        {
            Vector3 heightCorrectedPoint = new Vector3(lookPoint.x, transform.position.y, lookPoint.z);
            transform.LookAt(heightCorrectedPoint);
        }

        public void Roll(Vector3 direction)
        {
            Vector3 rollDirection = (direction.sqrMagnitude > 1f) ? direction.normalized : direction;
            Vector3 rollVelocity = rollDirection * m_MoveSpeed;
            m_CharacterController.Move(rollVelocity * Time.deltaTime);
        }
    }
}

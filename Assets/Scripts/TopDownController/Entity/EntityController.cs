using System.Collections.Generic;
using UnityEngine;


namespace FGSX.TopDownController.Entity
{
    [RequireComponent(typeof (CharacterController))]
    public class EntityController : MonoBehaviour
    {
        [SerializeField] private float m_MoveSpeed = 8f;
        [SerializeField] private float m_GravityScale = 1f;

        private CharacterController m_CharacterController;
        private Dictionary<GameObject, Vector3> m_AdditionalMovementVelocities;


        private void Awake()
        {
            m_CharacterController = GetComponent<CharacterController>();
        }

        private void Start()
        {
            m_AdditionalMovementVelocities = new Dictionary<GameObject, Vector3>();
        }

        private void Update()
        {
            ApplyAdditionalMovementVelocity();
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
            // Prevent from moving faster diagonally
            Vector3 rollDirection = (direction.sqrMagnitude > 1f) ? direction.normalized : direction;
            Vector3 rollVelocity = rollDirection * m_MoveSpeed;
            m_CharacterController.Move(rollVelocity * Time.deltaTime);
        }

        public void AddAdditionalMovementVelocity(GameObject gameObject, Vector3 velocity)
        {
            if (m_AdditionalMovementVelocities.ContainsKey(gameObject))
            {
                RemoveAdditionalMovementVelocity(gameObject);
            }

            m_AdditionalMovementVelocities.Add(gameObject, velocity);
        }

        public void RemoveAdditionalMovementVelocity(GameObject gameObject)
        {
            m_AdditionalMovementVelocities.Remove(gameObject);
        }


        private void ApplyAdditionalMovementVelocity()
        {
            m_CharacterController.Move(CalculateAdditionalMovementVelocity() * Time.deltaTime);
        }

        private Vector3 CalculateAdditionalMovementVelocity()
        {
            Vector3 velocity = Vector3.zero;

            foreach (Vector3 additionalVelocity in m_AdditionalMovementVelocities.Values)
            {
                velocity += additionalVelocity;
            }

            return velocity;
        }
    }
}

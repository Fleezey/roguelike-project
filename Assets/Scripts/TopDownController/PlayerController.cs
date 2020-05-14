using System.Collections;
using UnityEngine;


namespace FGSX.TopDownController
{
    [RequireComponent(typeof (CharacterController))]
    public class PlayerController : MonoBehaviour
    {
        public Vector3 Velocity => m_CharacterController.velocity;

        public bool IsMovementInputBlocked { get; private set; }

        [SerializeField]
        private float m_MoveSpeed = 8f;
        
        [SerializeField]
        private float m_GravityScale = 1f;


        private float m_CurrentSpeed;
        private CharacterController m_CharacterController;


        private Vector3 m_Velocity;
        private Rigidbody m_Rigidbody;
        private PlayerAnimations m_PlayerAnimations;
        private bool m_IsRolling;


        private void Awake()
        {
            m_CharacterController = GetComponent<CharacterController>();

            m_PlayerAnimations = GetComponent<PlayerAnimations>();
            m_PlayerAnimations.m_OnRollEnd += EndRoll;
        }


        public void Move(Vector3 inputDirection)
        {
            if (IsMovementInputBlocked)
            {
                return;
            }

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


        public void StartRoll(Vector3 direction)
        {
            if (m_IsRolling)
            {
                return;
            }

            m_IsRolling = true;
            IsMovementInputBlocked = true;

            StartCoroutine(Roll(direction));
        }

        private IEnumerator Roll(Vector3 direction)
        {
            while (m_IsRolling)
            {
                m_CharacterController.Move(direction * (m_MoveSpeed * 0.60f) * Time.deltaTime);
                yield return null;
            }
        }

        private void EndRoll()
        {
            m_IsRolling = false;
            IsMovementInputBlocked = false;
        }
    }
}

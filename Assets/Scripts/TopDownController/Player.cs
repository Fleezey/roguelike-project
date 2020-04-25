using UnityEngine;


namespace FGSX.TopDownController
{
    [RequireComponent(typeof (PlayerController))]
    public class Player : LivingEntity
    {
        public Crosshair m_Crosshair;
        [Tooltip("Distance from the origin that the crosshair is forced to have when using a gamepad")]
        public float m_CrosshairOffsetDistance = 8f;
        private Vector3 m_LastCrosshairPosition;
        private Vector3 m_LastAimInput;

        public bool m_IsUsingGamepad = false;

        private Camera m_ViewCamera;
        private PlayerController m_Controller;


        private void Awake()
        {
            m_Controller = GetComponent<PlayerController>();
            m_ViewCamera = Camera.main;
        }

        private void Update()
        {
            HandleMovementInput();
            HandleRotationInput();
        }


        private void HandleMovementInput()
        {
            Vector3 moveInput = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical"));
            m_Controller.Move(moveInput);
        }

        private void HandleRotationInput() {

            float rayDistance;

            Plane groundPlane = new Plane(transform.up, transform.position);
            Ray ray = GetRotationRay();
            if (groundPlane.Raycast(ray, out rayDistance))
            {
                float offsetDistance = m_IsUsingGamepad ? m_CrosshairOffsetDistance : 0f;
                Vector3 lookAtPosition = LookAt(ray, rayDistance, offsetDistance);
                m_LastCrosshairPosition = lookAtPosition;
            }
        }

        private Ray GetRotationRay()
        {
            if (m_IsUsingGamepad)
            {
                Vector3 aimInput = new Vector3(Input.GetAxisRaw("Aim Horizontal"), 0, Input.GetAxisRaw("Aim Vertical"));
                m_LastAimInput = aimInput;
                
                if (aimInput.magnitude == 0f) {
                    aimInput = m_LastCrosshairPosition;
                }

                return new Ray(
                    transform.position + aimInput.normalized + transform.up,
                    (transform.up * -1)
                );
            }

            return m_ViewCamera.ScreenPointToRay(Input.mousePosition);
        }

        private Vector3 LookAt(Ray ray, float rayDistance, float forcedOffsetDistanceFromOrigin)
        {
            Vector3 point = ray.GetPoint(rayDistance);
            Vector3 updatedCrosshairPosition = m_Crosshair.MoveTo(transform.position, point, forcedOffsetDistanceFromOrigin);
            m_Controller.LookAt(updatedCrosshairPosition);
            return updatedCrosshairPosition;
        }
    }
}

using UnityEngine;


namespace FGSX.TopDownController
{
    [RequireComponent(typeof (PlayerController))]
    public class Player : LivingEntity
    {
        public float m_MoveSpeed = 5f;

        public Crosshair m_Crosshair;

        private Camera m_ViewCamera;
        private PlayerController m_Controller;


        protected override void Start()
        {
            base.Start();

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
            Vector3 moveVelocity = moveInput.normalized * m_MoveSpeed;
            m_Controller.Move(moveVelocity);
        }

        private void HandleRotationInput() {
            Ray ray = m_ViewCamera.ScreenPointToRay(Input.mousePosition);
            Plane groundPlane = new Plane(Vector3.up, Vector3.up * transform.position.y);
            float rayDistance;

            if (groundPlane.Raycast(ray, out rayDistance)) {
                Vector3 point = ray.GetPoint(rayDistance);
                m_Controller.LookAt(point);
                m_Crosshair.transform.position = point;
                m_Crosshair.DetectTargets(ray);

                if ((new Vector2(point.x, point.z) - new Vector2(transform.position.x, transform.position.z)).sqrMagnitude > 3.5) {
                    // Aim it
                }

#if DEBUG_CAMERA
                Debug.DrawLine(ray.origin, point, Color.red);
#endif
            }
        }
    }
}

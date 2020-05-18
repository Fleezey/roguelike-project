using UnityEngine;


namespace FGSX.TopDownController.Entity
{
    public class Player : Living
    {
        public Animator Animator => m_Animator;
        public Crosshair Crosshair => m_Crosshair;
        public PlayerAnimations PlayerAnimations => m_PlayerAnimations;

        [SerializeField] private Animator m_Animator;
        [SerializeField] private Crosshair m_Crosshair;
        [SerializeField] private PlayerAnimations m_PlayerAnimations;
        private Camera m_ViewCamera;


        protected override void Awake()
        {
            base.Awake();

            m_ViewCamera = Camera.main;
        }

        protected override void Update()
        {
            base.Update();

            HandleRotationInput();
        }

        private void HandleRotationInput() {

            float rayDistance;

            Plane groundPlane = new Plane(transform.up, transform.position);
            Ray ray = m_ViewCamera.ScreenPointToRay(Input.mousePosition);
            if (groundPlane.Raycast(ray, out rayDistance))
            {
                LookAt(ray, rayDistance, 0f);
            }
        }

        private Vector3 LookAt(Ray ray, float rayDistance, float forcedOffsetDistanceFromOrigin)
        {
            Vector3 point = ray.GetPoint(rayDistance);
            Vector3 updatedCrosshairPosition = m_Crosshair.MoveTo(transform.position, point, forcedOffsetDistanceFromOrigin);
            Controller.LookAt(updatedCrosshairPosition);
            return updatedCrosshairPosition;
        }
    }
}
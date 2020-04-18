using UnityEngine;


namespace FGSX.TopDownController
{
    public class TopDownCamera : MonoBehaviour
    {
        [SerializeField]
        [Tooltip("Target that the camera should follow")]
        private Transform m_Target;

        [Header("Position Properties")]
        [SerializeField]
        [Tooltip("How high should the camera be from the target")]
        private float m_Height = 12f;

        [SerializeField]
        [Tooltip("How far should the camera be from the target")]
        private float m_Distance = 6f;

        [Header("Offset Properties")]
        [SerializeField]
        [Tooltip("Maximum distance for the camera offset")]
        [Range(0, 10)]
        private float m_OffsetMaxDistance = 5f;

        [SerializeField]
        [Tooltip("Percentage of the distance that will be used to calculate offset")]
        [Range(0, 1)]
        private float m_OffsetPercentage = 0.5f; 

        [SerializeField]
        [Tooltip("How long should the offset take")]
        [Range(0, 1)]
        private float m_OffsetSmoothTime = 5f;

        private Camera m_Camera;
        private Crosshair m_PlayerCrosshair;
        private Vector3 m_OffsetVelocity;


        private void Awake()
        {
            m_Camera = GetComponent<Camera>();
            SetTarget(m_Target.gameObject);
        }

        private void FixedUpdate()
        {
            UpdateCameraPosition();
        }


        public void SetTarget(GameObject target)
        {
            m_Target = target.transform;

            Player player = m_Target.GetComponent<Player>();
            if (player != null)
            {
                m_PlayerCrosshair = player.m_Crosshair;
            }
        }


        private Vector3 GetCameraPosition()
        {
            if (m_Target)
            {
                return m_Target.position + (Vector3.forward * -m_Distance) + (Vector3.up * m_Height);
            }

            return transform.position;
        }

        private Vector3 CalculateCameraOffset()
        {
            if (m_Target && m_PlayerCrosshair)
            {
                Vector3 offsetTargetPosition = m_PlayerCrosshair.transform.position;
                Vector3 offsetDirection = (offsetTargetPosition - m_Target.position).normalized;

                float offsetDistance = Vector3.Distance(offsetTargetPosition, m_Target.position);
                offsetDistance *= m_OffsetPercentage;
                offsetDistance = Mathf.Clamp(offsetDistance, 0, m_OffsetMaxDistance);

                return offsetDirection * offsetDistance;
            }

            return Vector3.zero;
        }

        private void UpdateCameraPosition()
        {
            Vector3 newPosition = GetCameraPosition() + CalculateCameraOffset();
            newPosition.y = transform.position.y;

            transform.position = Vector3.SmoothDamp(transform.position, newPosition, ref m_OffsetVelocity, m_OffsetSmoothTime);
        }
    }
}

using UnityEngine;


namespace FGSX.TopDownController
{
    public class Crosshair : MonoBehaviour
    {
        public LayerMask m_TargetMask;
        public float m_MoveTime = 0.01f;

        public SpriteRenderer m_Dot;
        public Color m_DotHighlightColor;
        private Color m_DotInitialColor;


        private void Start()
        {
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.Confined;
            m_DotInitialColor = m_Dot.color;
        }

        private void Update()
        {
            transform.Rotate(Vector3.forward * -40f * Time.deltaTime);
        }


        public Vector3 MoveTo(Vector3 origin, Vector3 targetPosition, float offsetDistance)
        {
            if (!Mathf.Approximately(offsetDistance, 0f))
            {
                Vector3 direction = (targetPosition - origin).normalized;
                transform.position = Vector3.Lerp(transform.position, origin + (direction * offsetDistance), m_MoveTime);
            }
            else
            {
                transform.position = targetPosition;
            }

            return transform.position;
        }

        public Vector3 MoveTo(Vector3 origin, Vector3 targetPosition)
        {
            return MoveTo(origin, targetPosition, 0f);
        }
    }
}

using UnityEngine;


namespace FGSX.TopDownController
{
    public class Crosshair : MonoBehaviour
    {
        public LayerMask m_TargetMask;

        public SpriteRenderer m_Dot;
        public Color m_DotHighlightColor;
        private Color m_DotInitialColor;


        private void Start() {
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.Confined;
            m_DotInitialColor = m_Dot.color;
        }

        private void Update() {
            transform.Rotate(Vector3.forward * -40f * Time.deltaTime);
        }

        public void DetectTargets(Ray ray) {
            if (Physics.Raycast(ray, 100, m_TargetMask)) {
                m_Dot.color = m_DotHighlightColor;
            } else {
                m_Dot.color = m_DotInitialColor;
            }
        }
    }
}

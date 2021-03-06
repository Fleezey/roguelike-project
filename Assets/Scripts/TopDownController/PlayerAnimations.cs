using System;
using UnityEngine;


namespace FGSX
{
    [RequireComponent(typeof (Animator))]
    public class PlayerAnimations : MonoBehaviour
    {
        public Action m_OnRollEnd;

        public void Anim_OnRollEnd()
        {
            if (m_OnRollEnd != null)
            {
                m_OnRollEnd();
            }
        }
    }
}
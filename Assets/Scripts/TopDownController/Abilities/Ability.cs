using System;
using UnityEngine;


namespace FGSX.Abilities
{
    public abstract class Ability : ScriptableObject
    {
        public string m_Name = "New Ability";
        public float m_Cooldown = 1f;
        public bool m_IsContinuous = false;

        public abstract void Initialize(GameObject gameObject);
        public abstract void TriggerAbility();
    }
}


#if UNITY_EDITOR
using System.Collections;
using System;
using UnityEngine;
using UnityEditor;

public class VerticalBoxStart : MaterialPropertyDrawer
{
    protected Color Col = Color.white;
    protected String Label = "";
    protected float Dimmer = 1.15f;

    #region
    public VerticalBoxStart(){
        Col = Color.white;
    }

    public VerticalBoxStart(string label) {
        Col = Color.white;
        Label = label;
    }

    public VerticalBoxStart(float level) {
        float dimmerValue = Mathf.Pow(Dimmer, level - 1.0f);
        Col = new Color(GUI.backgroundColor.r / dimmerValue, GUI.backgroundColor.b / dimmerValue, GUI.backgroundColor.g / dimmerValue, 1.0f);
    }

    public VerticalBoxStart(string label, float level) {
        float dimmerValue = Mathf.Pow(Dimmer, level - 1.0f);
        Col = new Color(GUI.backgroundColor.r / dimmerValue, GUI.backgroundColor.b / dimmerValue, GUI.backgroundColor.g / dimmerValue, 1.0f);
        Label = label;
    }

    public VerticalBoxStart(string label, float r, float g, float b) {
        Label = label;
        Col = new Color(r, g, b, 1.0f);
    }
    #endregion

    public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor){
        GUI.backgroundColor = Col;
        GUILayout.BeginVertical("", GUI.skin.box);
        GUI.backgroundColor = Color.white;
        if(Label != ""){
            EditorGUILayout.LabelField(Label, EditorStyles.boldLabel);
        }
    }

    public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor){
        return 0;
    }  
}

public class VerticalBoxEnd : MaterialPropertyDrawer
{
    public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor){
        GUILayout.EndVertical();
        GUI.backgroundColor = Color.white;
    }

    public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor){
        return 0;
    }
}
#endif
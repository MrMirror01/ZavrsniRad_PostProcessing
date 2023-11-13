using static UnityEngine.GraphicsBuffer;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;
using System;
using System.Reflection;

[CustomEditor(typeof(EffectGroup))]
public class EffectGroupEditor : Editor
{
	private void OnEnable()
	{
		
	}

	private void DrawObjectFields(Effect obj)
	{
		/*EditorGUI.BeginChangeCheck();

		SerializedObject serializedObject = new SerializedObject(obj);

		SerializedProperty iterator = serializedObject.GetIterator();
		bool enterChildren = true;
		while (iterator.NextVisible(enterChildren))
		{
			if (iterator.name != "m_Script")
			{
				EditorGUILayout.PropertyField(iterator, true);
			}
			enterChildren = false;
		}

		if (EditorGUI.EndChangeCheck())
		{
			serializedObject.ApplyModifiedProperties();
		}*/
	}

	public override void OnInspectorGUI()
	{
		/*EffectGroup effectGroup = (EffectGroup)target;

		effectGroup.effects.Clear();
		if (GUILayout.Button("Add Effect"))
		{
			Type type = EffectGroup.effectTypes[(int)effectGroup.addedEffect];
			effectGroup.effects.Add((Effect)Activator.CreateInstance(type));
		}

		foreach (Effect effect in effectGroup.effects)
		{
			DrawObjectFields(effect);
		}*/

		DrawDefaultInspector();
	}
}
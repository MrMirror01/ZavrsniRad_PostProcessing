using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using UnityEngine;

[Serializable]
public class AdvancedColorCorrection : Effect
{
	[Range(0.0f, 5.0f)]
	public float exposure;

	[Header("White balance"), Range(-1.67f, 1.67f), Tooltip("Yellow/Blue")]
	public float temperature;
	[Range(-1.67f, 1.67f), Tooltip("Pink/Green")]
	public float tint;

	[Header("Contrast"), Range(0.0f, 3.0f), InspectorName("R")]
	public float contrastR;
	[Range(0.0f, 3.0f), InspectorName("G")]
	public float contrastG;
	[Range(0.0f, 3.0f), InspectorName("B")]
	public float contrastB;

	[Header("Brightness"), Range(-1f, 1f), InspectorName("R")]
	public float brightnessR;
	[Range(-1f, 1f), InspectorName("G")]
	public float brightnessG;
	[Range(-1f, 1f), InspectorName("B")]
	public float brightnessB;

	[Header("Saturation"), Range(0f, 3f), InspectorName("R")]
	public float saturationR;
	[Range(0f, 3f), InspectorName("G")]
	public float saturationG;
	[Range(0f, 3f), InspectorName("B")]
	public float saturationB;

	[Range(0.0f, 3.0f), Tooltip("Default value is 2.2"), Space(3)]
	public float gamma = 2.2f;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/AdvancedColorCorrection"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);
		mat.SetFloat("_Exposure", exposure);
		mat.SetFloat("_Temperature", temperature);
		mat.SetFloat("_Tint", tint);
		mat.SetVector("_Contrast", new Vector4(contrastR, contrastG, contrastB, 0f));
		mat.SetVector("_Brightness", new Vector4(brightnessR, brightnessG, brightnessB, 0f));
		mat.SetVector("_Saturation", new Vector4(saturationR, saturationG, saturationB, 0f));
		mat.SetFloat("_Gamma", gamma);

		Graphics.Blit(tex, tex, mat);
	}
}

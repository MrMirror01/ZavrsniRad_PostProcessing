using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class ThickOutlines : Effect
{
    [Range(1, 10)]
    public int thickness = 3;
    [Range(0, 2000)]
    public float depthFactor = 1000;
    [Range(1.0f, 15.0f)]
    public float sharpness = 3.0f;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/ThickOutlines"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);
        mat.SetInt("_Thickness", thickness);
        mat.SetFloat("_DepthFactor", depthFactor);
        mat.SetFloat("_Sharpness", sharpness);

		Graphics.Blit(tex, tex, mat);
	}
}

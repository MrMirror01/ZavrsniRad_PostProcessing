using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.EditorTools;
using UnityEngine;
using UnityEditor;

[Serializable]
public class Blur : Effect
{
    public enum BlurType
    {
        BoxBlur = 0,
        WeightedByDistance = 1,
        GaussianBlur = 2,
        OptimisedGaussianBlur = 3,
    }

    public BlurType type;
    [Range(1, 25)]
    public int iterations = 1;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/Blur"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);

		for (int i = 0; i < iterations; i++)
		{
			Graphics.Blit(tex, tex, mat, (int)type);
			if (type == BlurType.OptimisedGaussianBlur)
				Graphics.Blit(tex, tex, mat, (int)type + 1); //drugi pass
		}
	}
}

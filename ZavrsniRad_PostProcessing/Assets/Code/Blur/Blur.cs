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
		BokehBlur = 2,
		BokehBlurWithInverseKarisAverge = 3,
		GaussianBlur = 4,
        OptimisedGaussianBlur = 5,
    }

    public BlurType type;
    [Range(1, 25)]
    public int iterations = 1;
	[Range(1f, 5.5f), Tooltip("Non integers are better: e.g. 2.5 is better than 2")]
	public float kernelSize = 1f;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/Blur"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);
		mat.SetFloat("_KernelSize", kernelSize);

		for (int i = 0; i < iterations; i++)
		{
			Graphics.Blit(tex, tex, mat, (int)type);
			if (type == BlurType.OptimisedGaussianBlur)
				Graphics.Blit(tex, tex, mat, (int)type + 1); //drugi pass
		}

		if (kernelSize >= 1.5f) //da se bi minimizirali artefakti zbog manjeg broja uzoraka
		{
			mat.SetFloat("_KernelSize", 1f);
			Graphics.Blit(tex, tex, mat, (int)BlurType.BoxBlur);
		}
	}
}

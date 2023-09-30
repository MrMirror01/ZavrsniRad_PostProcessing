using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static Unity.VisualScripting.Member;

[Serializable]
public class Dithering : Effect
{
	public enum DitherType
	{
		BlackAndWhite4x4 = 0,
		BlackAndWhite8x8 = 1,
		Colored4x4 = 2,
		Colored8x8 = 3
	}

	public ComputeShader ditherShader;
	public DitherType type;
	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/Swipe"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}

		ditherShader.SetTexture((int)type, "Source", tex);

		RenderTexture outputTexture = RenderTexture.GetTemporary(tex.width, tex.height, 0);
		outputTexture.enableRandomWrite = true;

		ditherShader.SetTexture((int)type, "Result", outputTexture);
		if (type == DitherType.BlackAndWhite4x4 || type == DitherType.Colored4x4)
			ditherShader.Dispatch((int)type, tex.width / 4 + 1, tex.height / 4 + 1, 1);
		else
			ditherShader.Dispatch((int)type, tex.width / 8 + 1, tex.height / 8 + 1, 1);

		mat.SetFloat("_Swipe", swipe);
		mat.SetTexture("_OtherTex", outputTexture);
		Graphics.Blit(tex, tex, mat);

		RenderTexture.ReleaseTemporary(outputTexture);
	}
}

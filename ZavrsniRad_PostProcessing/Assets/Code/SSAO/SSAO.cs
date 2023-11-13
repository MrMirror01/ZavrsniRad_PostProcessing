using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class SSAO : Effect
{
	public float hemisphereRadius;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/SSAO2"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}

		mat.SetFloat("_Swipe", swipe);
		mat.SetFloat("_HemisphereRadius", hemisphereRadius);
		mat.SetMatrix("_ProjectionMatrix", Camera.main.projectionMatrix);
		mat.SetMatrix("_InverseProjectionMatrix", Camera.main.projectionMatrix.inverse);

		Graphics.Blit(tex, tex, mat);
	}
}

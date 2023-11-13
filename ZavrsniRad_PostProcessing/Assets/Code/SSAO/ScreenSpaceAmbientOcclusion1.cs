using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[Serializable]
public class ScreenSpaceAmbientOcclusion1 : Effect
{
	private enum Passes
	{
		Noise = 0,
		ApplySSAO = 1,
		Blur = 2,
	}

	[Range(1, 30)]
	public int kernelSize = 1;
	public Texture2D noiseTexture;
	public float radius = 1;

	public void generateNoiseTexture()
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/ScreenSpaceAmbientOcclusion1"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}

		RenderTexture renderTex = new RenderTexture(4, 4, 0);
		Texture2D noiseTexture = new Texture2D(4, 4, TextureFormat.RGB24, false);
		Graphics.Blit(renderTex, renderTex, mat, 0);

		RenderTexture.active = renderTex;
		noiseTexture.ReadPixels(new Rect(0, 0, renderTex.width, renderTex.height), 0, 0);
		noiseTexture.Apply();

		byte[] bytes = noiseTexture.EncodeToPNG();
		File.WriteAllBytes(Application.dataPath + @"\Code\SSAO\noise.png", bytes);
	}

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/ScreenSpaceAmbientOcclusion"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);
		mat.SetInt("_KernelSize", kernelSize);
		mat.SetTexture("_NoiseTex", noiseTexture);
		mat.SetFloat("_Radius", radius);
		mat.SetMatrix("_InverseProjectionMat", Camera.main.projectionMatrix.inverse);
		mat.SetFloat("_TanHalfFov", Mathf.Tan(Camera.main.fieldOfView * Mathf.Deg2Rad / 2));
		mat.SetFloat("_Aspect", Camera.main.aspect);

		Graphics.Blit(tex, tex, mat, (int)Passes.ApplySSAO);
	}
}

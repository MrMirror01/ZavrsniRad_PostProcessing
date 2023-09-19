using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class SharpenParameters : EffectParameter
{
	[Space(10)][Range(1, 25)]
	public int iterations = 1;
}

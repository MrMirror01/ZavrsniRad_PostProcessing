using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.EditorTools;
using UnityEngine;
using UnityEditor;

[Serializable]
public class BlurParameters : EffectParameter
{
    [Space(10)]
    public Shader shader;
    [Range(0, 32)]
    public int kernelSize;
}

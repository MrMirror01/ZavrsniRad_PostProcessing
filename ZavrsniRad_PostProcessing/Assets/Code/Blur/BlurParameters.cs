using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.EditorTools;
using UnityEngine;
using UnityEditor;

[Serializable]
public class BlurParameters : EffectParameter
{
    public enum BlurType
    {
        BoxBlur = 0,
        WeightedByDistance = 1,
        GaussianBlur = 2,
        OptimisedGaussianBlur = 3,
    }

    [Space(10)]
    public BlurType type;
    [Range(1, 25)]
    public int iterations = 1;
}

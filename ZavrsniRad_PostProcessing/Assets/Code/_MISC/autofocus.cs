using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class autofocus : MonoBehaviour
{
    public Transform cameraTransform;
    public PostProcessingDriver PP;

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit;
        Physics.Raycast(new Ray(cameraTransform.position, cameraTransform.forward), out hit);

        PP.depthOfField.distance = Mathf.Lerp(PP.depthOfField.distance, hit.distance, 0.3f);
    }
}

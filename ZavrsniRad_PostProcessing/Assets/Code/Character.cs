using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Character : MonoBehaviour
{
	public CharacterController characterController;
	public float speed = 1.0f;
	public float gravty = 1.0f;

	public Transform cameraTransform;
	public float sensitivity = 2f;
	private float cameraVerticalRotation = 0.0f;

	// Start is called before the first frame update
	void Start()
	{
		Cursor.visible = false;
	}

	// Update is called once per frame
	void Update()
	{
		Vector3 move = transform.right * Input.GetAxis("Horizontal") + transform.up * -gravty * Time.deltaTime + transform.forward * Input.GetAxis("Vertical");
		characterController.SimpleMove(move * speed); //.Move(move * speed * Time.deltaTime);

		float inputX = Input.GetAxis("Mouse X") * sensitivity;
		float inputY = Input.GetAxis("Mouse Y") * sensitivity;

		cameraVerticalRotation -= inputY * Time.deltaTime;
		cameraVerticalRotation = Mathf.Clamp(cameraVerticalRotation, -90f, 90f);
		cameraTransform.localEulerAngles = Vector3.right * cameraVerticalRotation;

		transform.Rotate(Vector3.up * inputX * Time.deltaTime);
	}
}

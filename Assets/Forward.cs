using UnityEngine;
using System.Collections;

public class Forward : MonoBehaviour {
    private GameObject target;
	// Use this for initialization
	void Start () {
        target = GameObject.Find("finish");
        Debug.Log("İlerinin açısı " + transform.rotation.y);
    }

    // Update is called once per frame
    void Update () {
        transform.position = Vector3.Lerp(transform.position, target.transform.position, Time.deltaTime);
	}
}

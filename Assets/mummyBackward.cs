using UnityEngine;
using System.Collections;
using Vuforia;
using System;

public class mummyBackward : MonoBehaviour , IVirtualButtonEventHandler{
    private GameObject backward;
    private GameObject mummy;
    // Use this for initialization
    void Start () {
        backward = GameObject.Find("backwardVirtual");
        backward.GetComponent<VirtualButtonBehaviour>().RegisterEventHandler(this);

        mummy = GameObject.Find("mummy@run");
    }
	
	// Update is called once per frame
	void Update () {
	
	}
    public void OnButtonPressed(VirtualButtonAbstractBehaviour vb)
    {
        mummy.AddComponent<Backward>();
    }

    public void OnButtonReleased(VirtualButtonAbstractBehaviour vb)
    {
        Destroy(mummy.GetComponent<Backward>());
        mummy.transform.Rotate(new Vector3(0, 180, 0));
    }
}

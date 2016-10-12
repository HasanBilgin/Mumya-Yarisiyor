using UnityEngine;
using System.Collections;
using Vuforia;
using System;

public class mummyForward : MonoBehaviour , IVirtualButtonEventHandler {
    private GameObject forward;
    private GameObject mummy;
    // Use this for initialization
    void Start()
    {
        forward = GameObject.Find("forwardVirtual");
        forward.GetComponent<VirtualButtonBehaviour>().RegisterEventHandler(this);
        mummy = GameObject.Find("mummy@run");
    }

    // Update is called once per frame
    void Update()
    {

    }
    public void OnButtonPressed(VirtualButtonAbstractBehaviour vb)
    {
        mummy.AddComponent<Forward>();
    }

    public void OnButtonReleased(VirtualButtonAbstractBehaviour vb)
    {
        Destroy(mummy.GetComponent<Forward>());
        mummy.transform.Rotate(new Vector3(0, 180, 0));
    }
}

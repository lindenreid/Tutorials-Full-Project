using UnityEngine;

public class HeatmapCam : MonoBehaviour
{
    public Camera cam;

    void Start()
    {
        cam.cullingMask = 7;
    }
}

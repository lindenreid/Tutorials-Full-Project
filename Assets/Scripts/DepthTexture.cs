using UnityEngine;

[ExecuteInEditMode]
public class DepthTexture : MonoBehaviour {

   private Camera cam;
   public Material material;

   void Start () {
      cam = GetComponent<Camera>(); 
      cam.depthTextureMode = DepthTextureMode.Depth;
   }

   void OnRenderImage (RenderTexture source, RenderTexture destination){
      Graphics.Blit(source, destination, material);
   }
}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawOnTexture : MonoBehaviour {

	public Camera cam;
	public Color drawColor;
	public Renderer destinationRenderer;
	public int TextureSize;
	public int Radius;
	public float maxSeconds = 30;
	public Color BlurColor;

	private Texture2D texture;

	void Start ()
	{
		texture = new Texture2D(TextureSize, TextureSize, TextureFormat.RFloat, false, true); 
		for (int i = 0; i < texture.height; i++)
		{
			for (int j = 0; j < texture.width; j++)
			{
				texture.SetPixel(i, j, BlurColor);
			}
		}
		texture.Apply();
		destinationRenderer.material.SetTexture("_MouseMap", texture);
		destinationRenderer.material.SetFloat("_MaxSeconds", maxSeconds);
	}

	void OnMouseDrag ()
	{
		Ray ray = cam.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if(Physics.Raycast(ray, out hit, 100))
        {
			// younger = redder (higher r)
			// older = blacker
			float r = Time.timeSinceLevelLoad / maxSeconds;
			Debug.Log("Time: " + Time.timeSinceLevelLoad + "; r: " + r);
			Color color = new Color(r, 0, 0, 1);

			int x = (int)(hit.textureCoord.x*texture.width);
			int y = (int)(hit.textureCoord.y*texture.height);

			texture.SetPixel(x, y, color);

			for (int i = 0; i < texture.height; i++)
			{
				for (int j = 0; j < texture.width; j++)
				{
					float dist = Vector2.Distance(new Vector2(i,j), new Vector2(x,y));
					if(dist <= Radius)
						texture.SetPixel(i, j, color);
				}
			}

			texture.Apply();
			destinationRenderer.material.SetTexture("_MouseMap", texture);
        }
	}
}
using UnityEngine;
using UnityEditor;

public class RenderCubemapWindow : EditorWindow
{
    private Transform renderFromPosition;
    private Cubemap cubemap;

    [MenuItem("Tools/Render Cubemap")]
    public static void ShowWindow()
    {
        GetWindow<RenderCubemapWindow>("Render Cubemap");
    }

    private void OnGUI()
    {
        GUILayout.Label("Render Cubemap Settings", EditorStyles.boldLabel);

        renderFromPosition = (Transform)EditorGUILayout.ObjectField("Render From Position", renderFromPosition, typeof(Transform), true);
        cubemap = (Cubemap)EditorGUILayout.ObjectField("Cubemap", cubemap, typeof(Cubemap), false);

        if (GUILayout.Button("Render"))
        {
            RenderCubemap();
        }
    }

    private void RenderCubemap()
    {
        if (renderFromPosition == null || cubemap == null)
        {
            EditorUtility.DisplayDialog("Error", "Please assign both Transform and Cubemap.", "OK");
            return;
        }

        // Create temporary camera
        GameObject cameraObj = new GameObject("CubemapCamera");
        Camera camera = cameraObj.AddComponent<Camera>();
        camera.transform.position = renderFromPosition.position;

        // Render to cubemap
        RenderTexture rt = new RenderTexture(cubemap.width, cubemap.height, 24);
        camera.RenderToCubemap(cubemap);

        // Clean up
        DestroyImmediate(cameraObj);
    }
}
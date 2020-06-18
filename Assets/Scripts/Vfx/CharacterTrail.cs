using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(MeshFilter))]
public class CharacterTrail : MonoBehaviour
{
    [Header("Base Properties")]
    [SerializeField] private string m_MeshName = "Character Trail";
    [SerializeField] private bool m_RandomizeUvX = false;
    [SerializeField] private Vector3 m_Offset = new Vector3(0.0f, 0.0f, 0.0f);
    [SerializeField] private Material m_SharedMaterial = default;

    [Header("In Layer Properties")]
    [SerializeField] private int m_InLayerCount = 8;
    [SerializeField] private int m_InLayoutYDiv = 5;
    [SerializeField] private Vector2 m_InLayerWidthRange = new Vector2(1.0f, 0.5f);
    [SerializeField] private Vector2 m_InLayerHeightRange = new Vector2(1.0f, 1.0f);
    [SerializeField] private Vector2 m_InLayerLengthRange = new Vector2(10.0f, 12.0f);
    [SerializeField] private float m_InWaveLength = 1.0f;
    [SerializeField] private float m_InWaveExp = 10.0f;
    [SerializeField] private float m_InWaveScale = 1.0f;
    [Range(0.0f, 1.0f)]
    [SerializeField] private float m_InTighterTip = 1.0f;

    [Header("Out Layer Properties")]
    [SerializeField] private int m_OutLayerCount = 8;
    [SerializeField] private int m_OutLayoutYDiv = 5;
    [SerializeField] private Vector2 m_OutLayerWidthRange = new Vector2(1.0f, 0.5f);
    [SerializeField] private Vector2 m_OutLayerHeightRange = new Vector2(1.0f, 1.0f);
    [SerializeField] private Vector2 m_OutLayerLengthRange = new Vector2(2.0f, 3.0f);
    [SerializeField] private float m_OutWaveLength = 1.0f;
    [SerializeField] private float m_OutWaveExp = 10.0f;
    [SerializeField] private float m_OutWaveScale = 1.0f;
    [Range(0.0f, 1.0f)]
    [SerializeField] private float m_OutTighterTip = 1.0f;

    [Header("Create")]
    [SerializeField] private bool m_Generate = false;
    [SerializeField] private float m_Value = default;

    [Header("Animation Properties")]
    [SerializeField] private string m_MaterialProperty = "_DirectionFrom";
    [SerializeField] private float m_TimeTick = default;
    [SerializeField] private float m_Tick = default;
    [SerializeField] private float m_TimeLoop = default;
    [SerializeField] private float m_WaveIntensity = default;
    [SerializeField] private int m_TrailLength = default;
    [SerializeField] private float m_Damping = default;


    private MeshRenderer m_MeshRenderer;
    private MeshFilter m_MeshFilter;
    private Mesh m_Mesh;

    private float m_DirectionFrom;
    private float m_Time;
    private Vector3[] m_Directions;

    private void Awake()
    {
        if(GetComponent<MeshRenderer>() != null)
        {
            m_MeshRenderer = GetComponent<MeshRenderer>();
        }

        if(GetComponent<MeshFilter>() != null)
        {
            m_MeshFilter = GetComponent<MeshFilter>();
        }

        GenerateMesh();
    }

    private void Update()
    {
        if(m_Generate)
        {
            GenerateMesh();
        }
    }

    private void Start()
    {
        m_Directions = new Vector3[m_TrailLength];

        for(int i = 0; i < m_TrailLength; i++)
        {
            m_Directions[i] = transform.forward;
        }

        StartCoroutine(TrailDirectionUpdate());
    }

    // Generate mesh vertices, normals, triangles
    private void GenerateMesh()
    {
        Mesh mesh = CreateMesh();
        if(mesh != null)
        {
            // In variables
            int inSegTriIndexCount = ((m_InLayoutYDiv - 1) * 2 + 1) * 3;
            int inTriIndexCount = m_InLayerCount * inSegTriIndexCount;
            int inSegVertCount = ((m_InLayoutYDiv - 1) * 2 + 3);
            int inVertCount = m_InLayerCount * inSegVertCount;

            // Out variables
            int outSegTriIndexCount = ((m_OutLayoutYDiv - 1) * 2 + 1) * 3;
            int outTriIndexCount = m_OutLayerCount * outSegTriIndexCount;
            int outSegVertCount = ((m_OutLayoutYDiv - 1) * 2 + 3);
            int outVertCount = m_OutLayerCount * outSegVertCount; 

            // Initialize mesh array members
            int[] triangleIndices = new int[inTriIndexCount + outTriIndexCount];
            Vector3[] vertices = new Vector3[inVertCount + outVertCount];
            Vector3[] normals = new Vector3[inVertCount + outVertCount];
            Vector2[] uvs = new Vector2[inVertCount + outVertCount];

            // Create vertices and uvs in
            for( int iLC = 0; iLC < m_InLayerCount; iLC++ )
            {
                int segCount = iLC *  inSegVertCount;
                vertices[segCount] = m_Offset;
                int randomInt = Random.Range(0, 50);
                float inLayerLength = Random.Range(m_InLayerLengthRange.x, m_InLayerLengthRange.y);
                float inLayerHeight = Random.Range(m_InLayerHeightRange.x, m_InLayerHeightRange.y);
                float inLayerWidth = Random.Range(m_InLayerWidthRange.x, m_InLayerWidthRange.y);

                float deg = 360.0f / m_InLayerCount * iLC;
                for(int yDiv = 0; yDiv < m_InLayoutYDiv; yDiv++ )
                {
                    // Position
                    int lineCount = segCount + yDiv * 2 + 1;
                    float x = inLayerLength / (float)m_InLayoutYDiv * (float)(yDiv + 1);
                    float lowEndX = 1.0f / (float)m_InLayoutYDiv * (float)(m_InLayoutYDiv - yDiv - 1);
                    lowEndX = Mathf.Lerp(1.0f, inLayerHeight * lowEndX, m_InTighterTip);
                    float y = Mathf.Atan(Mathf.Pow(x, m_InWaveExp)*m_InWaveLength) * lowEndX * m_InWaveScale;

                    Vector2 left = new Vector2(inLayerWidth/2.0f, y);
                    Vector2 right = new Vector2(-inLayerWidth/2.0f, y);
                    left = RotateV2(left, deg);
                    right = RotateV2(right, deg);
                    vertices[lineCount] = new Vector3(left.x, left.y, -x) + m_Offset;
                    vertices[lineCount + 1] = new Vector3(right.x, right.y, -x) + m_Offset;

                    // UV
                    float uvY = 1.0f/((float)m_InLayoutYDiv) * (float)(yDiv + 1);
                    if(m_RandomizeUvX)
                    {
                        uvs[lineCount] = new Vector2((float)randomInt, uvY);
                        uvs[lineCount + 1] = new Vector2((float)randomInt + 0.99f, uvY);
                    }
                    else
                    {
                        uvs[lineCount] = new Vector2((float)iLC, uvY);
                        uvs[lineCount + 1] = new Vector2((float)iLC + 0.99f, uvY);
                    }
                }
                if(m_RandomizeUvX)
                {
                    uvs[segCount] = new Vector2((float)randomInt + 0.5f, 0.0f);
                }
                else
                {
                    uvs[segCount] = new Vector2((float)iLC + 0.5f, 0.0f);
                }
            }

            // Create vertices and uvs out
            for( int oLC = m_InLayerCount; oLC < (m_InLayerCount + m_OutLayerCount); oLC++ )
            {
                int segCount = (oLC- m_InLayerCount) * outSegVertCount + inVertCount;
                vertices[segCount] = m_Offset;
                int randomInt = Random.Range(0, 50);
                float outLayerLength = Random.Range(m_OutLayerLengthRange.x, m_OutLayerLengthRange.y);
                float outLayerHeight = Random.Range(m_OutLayerHeightRange.x, m_OutLayerHeightRange.y);
                float outLayerWidth = Random.Range(m_OutLayerWidthRange.x, m_OutLayerWidthRange.y);

                float deg = 360.0f / m_OutLayerCount * oLC;
                for(int yDiv = 0; yDiv < m_OutLayoutYDiv; yDiv++ )
                {
                    // Position
                    int lineCount = segCount + yDiv * 2 + 1;
                    float x = outLayerLength / (float)m_OutLayoutYDiv * (float)(yDiv + 1);
                    float lowEndX = 1.0f / (float)m_OutLayoutYDiv * (float)(m_OutLayoutYDiv - yDiv - 1);
                    lowEndX = Mathf.Lerp(1.0f, outLayerHeight * lowEndX, m_OutTighterTip);
                    float y = Mathf.Atan(Mathf.Pow(x, m_OutWaveExp)*m_OutWaveLength) * lowEndX * m_OutWaveScale;

                    Vector2 left = new Vector2(outLayerWidth/2.0f, y);
                    Vector2 right = new Vector2(-outLayerWidth/2.0f, y);
                    left = RotateV2(left, deg);
                    right = RotateV2(right, deg);
                    vertices[lineCount] = new Vector3(left.x, left.y, -x) + m_Offset;
                    vertices[lineCount + 1] = new Vector3(right.x, right.y, -x) + m_Offset;

                    // UV
                    float uvY = 1.0f/((float)m_OutLayoutYDiv) * (float)(yDiv + 1);
                    if(m_RandomizeUvX)
                    {
                        uvs[lineCount] = new Vector2((float)randomInt, uvY);
                        uvs[lineCount + 1] = new Vector2((float)randomInt + 0.99f, uvY);
                    }
                    else
                    {
                        uvs[lineCount] = new Vector2((float)oLC, uvY);
                        uvs[lineCount + 1] = new Vector2((float)oLC + 0.99f, uvY);
                    }
                }
                if(m_RandomizeUvX)
                {
                    uvs[segCount] = new Vector2((float)randomInt + 0.5f, 0.0f);
                }
                else
                {
                    uvs[segCount] = new Vector2((float)oLC + 0.5f, 0.0f);
                }
            }
            
            // Create triangles in
            int iC= 0;
            for( int iLC = 0; iLC < m_InLayerCount; iLC++ )
            {
                int segCount = iLC *  inSegVertCount;
                triangleIndices[iC] = segCount; iC++;
                triangleIndices[iC] = segCount + 1; iC++;
                triangleIndices[iC] = segCount + 2; iC++;
                for(int yDiv = 0; yDiv < m_InLayoutYDiv - 1; yDiv++ )
                {
                    int lineCount = segCount + yDiv * 2 + 1;
                    triangleIndices[iC] = lineCount + 1; iC++;
                    triangleIndices[iC] = lineCount + 0; iC++;
                    triangleIndices[iC] = lineCount + 2; iC++;
                    
                    triangleIndices[iC] = lineCount + 1; iC++;
                    triangleIndices[iC] = lineCount + 2; iC++;
                    triangleIndices[iC] = lineCount + 3; iC++;
                }
            }

            // Create triangles out
            int oC= iC;
            for( int oLC = m_InLayerCount; oLC < (m_InLayerCount + m_OutLayerCount); oLC++ )
            {
                int segCount = (oLC - m_InLayerCount) * outSegVertCount + inVertCount;
                triangleIndices[oC] = segCount; oC++;
                triangleIndices[oC] = segCount + 1; oC++;
                triangleIndices[oC] = segCount + 2; oC++;
                for(int yDiv = 0; yDiv < m_OutLayoutYDiv - 1; yDiv++ )
                {
                    int lineCount = segCount + yDiv * 2 + 1;
                    triangleIndices[oC] = lineCount + 1; oC++;
                    triangleIndices[oC] = lineCount + 0; oC++;
                    triangleIndices[oC] = lineCount + 2; oC++;
                    
                    triangleIndices[oC] = lineCount + 1; oC++;
                    triangleIndices[oC] = lineCount + 2; oC++;
                    triangleIndices[oC] = lineCount + 3; oC++;
                }
            }

            mesh.Clear();
            mesh.vertices = vertices;
            mesh.normals = normals;
            mesh.uv = uvs;
            mesh.triangles = triangleIndices;
            mesh.RecalculateNormals();
            SetMaterial();
            Debug.Log(string.Format("Vert:{0}, Tri:{1}", vertices.Length, triangleIndices.Length/3));
        }
        Reactivate();
    }

    // Reactivate generate button
    private void Reactivate()
    {
        StartCoroutine(WaitToReturn(1.0f));
        m_Generate = false; 
    }

    // Create and set mesh
    private Mesh CreateMesh()
    {
        if(m_MeshFilter != null && m_MeshRenderer != null)
        {
            Mesh mesh = new Mesh(); 
            m_MeshFilter.mesh = mesh;
            mesh.name = m_MeshName;
            return mesh;
        }
        return null;
    }

    private IEnumerator WaitToReturn(float time)
    {
        yield return new WaitForSeconds(time);
    }

    private Vector2 RotateV2(Vector2 v, float degrees)
    {
        float sin = Mathf.Sin(degrees * Mathf.Deg2Rad);
        float cos = Mathf.Cos(degrees * Mathf.Deg2Rad);
        
        float tx = v.x;
        float ty = v.y;
        v.x = (cos * tx) - (sin * ty);
        v.y = (sin * tx) + (cos * ty);
        return v;
    }

    private void SetMaterial()
    {
        if(m_SharedMaterial != null)
        {
            Material materialInstance = Instantiate<Material>(m_SharedMaterial);
            if(m_MeshRenderer.sharedMaterials.Length < 1)
            {
                m_MeshRenderer.sharedMaterials = new Material[] {materialInstance};
            }
            else
            {
                m_MeshRenderer.sharedMaterials[0] = materialInstance;
            }
        }
    }

    private IEnumerator TrailDirectionUpdate()
    {
        float oldResult = 0.0f;
        while(true)
        {
            Vector3 currentForward = transform.forward;

            if(m_MeshRenderer.sharedMaterials[0])
            {
                if(m_MeshRenderer.sharedMaterials[0].HasProperty(m_MaterialProperty))
                {
                    Vector3 dividend = new Vector3(0.0f, 0.0f, 0.0f);
                    float divider = 0;
                    float multiplier;
                    
                    // Division
                    for(int i = 0; i < m_TrailLength; i++)
                    {
                        multiplier = Mathf.Pow((float)(i + 1), m_Damping);
                        dividend += m_Directions[i]  * multiplier;
                        divider += multiplier;
                    }
                    dividend = dividend / divider;

                    float result = Quaternion.FromToRotation(dividend, currentForward).eulerAngles.y;
                    result += Mathf.Sin(m_Time/m_TimeLoop * Mathf.PI * 2.0f) * m_WaveIntensity;
                    m_MeshRenderer.sharedMaterials[0].SetFloat(m_MaterialProperty, result);
                }
            }

            if(m_Time >= m_TimeLoop)
            {
                m_Time = 0.0f;
            }
            else
            {
                m_Time += m_Tick;
            }

            // Update Queue
            for(int i = 1; i < m_TrailLength; i++)
            {
                m_Directions[i - 1] = m_Directions[i];
            }
            m_Directions[m_TrailLength-1] = currentForward;

            yield return new WaitForSeconds(m_TimeTick);
        }
    }
}

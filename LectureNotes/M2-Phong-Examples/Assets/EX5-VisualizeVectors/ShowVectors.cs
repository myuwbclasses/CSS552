using UnityEditor;
using UnityEngine;

public class ShowVectors : MonoBehaviour
{
    class VecGroup {
        LineSegment nVec, lVec, vVec, hVec;
        Vector3 Pos;
        const float kVectorWidth = 0.1f;
        const float kVectorLength = 3.0f;
        public VecGroup()
        {
            nVec = LineSegment.CreateLineSegment();
            lVec = LineSegment.CreateLineSegment();
            vVec = LineSegment.CreateLineSegment();
            hVec = LineSegment.CreateLineSegment();
            
            nVec.SetWidth(kVectorWidth);
            lVec.SetWidth(kVectorWidth);
            vVec.SetWidth(kVectorWidth);
            hVec.SetWidth(kVectorWidth);

            nVec.GetComponent<Renderer>().material.color = Color.white;
            lVec.GetComponent<Renderer>().material.color = Color.blue;
            vVec.GetComponent<Renderer>().material.color = Color.red;
            hVec.GetComponent<Renderer>().material.color = Color.green;
        }
        public void SetAt(Vector3 at) {Pos = at; }
        public void UpdateN(Transform t, Vector3 n) { 
            nVec.transform.up = t.TransformDirection(n);
            nVec.SetEndPoints(Pos, Pos+kVectorLength*nVec.transform.up);
        }
        public void UpdateV(Transform t)
        {
            Vector3 d = t.localPosition - Pos;
            vVec.SetEndPoints(Pos, Pos+kVectorLength*d.normalized);
        }

        public void UpdateL(Vector3 p)
        {
            Vector3 d = p-Pos;
            lVec.SetEndPoints(Pos, Pos+kVectorLength*d.normalized);
        }

        public void UpdateH()
        {
            Vector3 d = 0.5f * (lVec.transform.up + vVec.transform.up);
            hVec.SetEndPoints(Pos, Pos+kVectorLength*d);
        }
        public void Update(Transform myT, Transform eyeT, Vector3 lightPt)
        {
            UpdateN(myT, Vector3.up);
            UpdateV(eyeT);
            UpdateL(lightPt);
            UpdateH();
        }
        public void ShowAllVectors(bool f)
        {
            nVec.gameObject.SetActive(f);
            vVec.gameObject.SetActive(f);
            lVec.gameObject.SetActive(f);
            hVec.gameObject.SetActive(f);
        }
    }
    // Assume to be attached to a plane

    public VizControl SceneController = null;
    VecGroup[] Vecs = null;

    void Start()
    {
        Vecs = new VecGroup[5];
        for (int i = 0; i < 5; i++)
            Vecs[i] = new VecGroup();
        float w = transform.localScale.x * 5f;
        float h = transform.localScale.z * 5f;
        Vecs[0].SetAt(transform.localPosition);
        Vecs[1].SetAt(transform.localPosition + new Vector3(w, 0, h));
        Vecs[2].SetAt(transform.localPosition + new Vector3(-w, 0, h));
        Vecs[3].SetAt(transform.localPosition + new Vector3(w, 0, -h));
        Vecs[4].SetAt(transform.localPosition + new Vector3(-w, 0, -h));
    }

    // Update is called once per frame
    void Update()
    {
        Transform eyeT = null;
        if (SceneController.UseMainCamera)
            eyeT = Camera.main.transform;
        else
            eyeT = SceneView.lastActiveSceneView.camera.transform;
        
        for (int i = 0; i<5; i++)
            Vecs[i].Update(transform, eyeT, SceneController.LightPosition.localPosition);
    }
}

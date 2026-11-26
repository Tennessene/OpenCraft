// Modified for OpenCraft (2026-11-26): User-Agent now identifies OpenCraft; community links point to the OpenCraft GitHub repo instead of upstream Discord, X and website (method names kept because scene buttons bind to them).
using System.IO;
using System.Threading.Tasks;
using UnityEngine.Networking;
using UnityEngine;
using UnityEngine.UI;

public class LoadLog : MonoBehaviour
{
    public TMPro.TextMeshProUGUI linkBox;
    public Button discord;

    private bool hasUploaded;
    
    private void Start()
    {
        linkBox.transform.parent.parent.GetComponent<Button>().onClick.AddListener(() =>
        {
            if (linkBox.text != "Loading...")
                Application.OpenURL(linkBox.text.Replace("<color=#5765f2><u>", ""));
        });
        
        discord.onClick.AddListener(() => Application.OpenURL("https://github.com/Tennessene/OpenCraft/issues"));
    }

    private class LogResponse
    {
        public string id;
    }
    
    public void UploadLog()
    {
        async Task Upload()
        {
            hasUploaded = true;
            string logtext;
            try
            {
                logtext = File.ReadAllText(Application.persistentDataPath + "/latestlog.txt");
            }
            catch (FileNotFoundException)
            {
                linkBox.text = $"No log to upload!";
                throw;
            }
        
            WWWForm form = new WWWForm();
            form.AddField("content", logtext);

            using UnityWebRequest www = UnityWebRequest.Post("https://api.mclo.gs/1/log", form);
            www.SetRequestHeader("User-Agent", "OpenCraft/" + Application.version + " (+https://github.com/Tennessene/OpenCraft)");
            www.SendWebRequest();

            while (!www.isDone)
                await Task.Delay(16);
            
            if (www.result != UnityWebRequest.Result.Success)
                Debug.LogError(www.error);
            else
            {
                string id = JsonUtility.FromJson<LogResponse>(www.downloadHandler.text).id;
                linkBox.text = $"<color=#5765f2><u>https://mclo.gs/" + id;
            }
        }

        if (!hasUploaded)
            Upload();
    }
}
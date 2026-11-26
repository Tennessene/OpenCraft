// Modified for OpenCraft (2026-11-26): community links point to the OpenCraft GitHub repo instead of upstream Discord, X and website (method names kept because scene buttons bind to them).
using UnityEngine;

public class OpenWebURL : MonoBehaviour
{
    public void OpenDiscord()
    {
        Application.OpenURL("https://github.com/Tennessene/OpenCraft/issues");
    }
    public void OpenX()
    {
        Application.OpenURL("https://github.com/Tennessene/OpenCraft");
    }
    public void OpenWebsite()
    {
        Application.OpenURL("https://github.com/Tennessene/OpenCraft");
    }
}

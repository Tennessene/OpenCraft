// Added for OpenCraft (2026-11-26). Original file.
//
// The lobby scenery was exported from the game, so it uses the game's own block and
// entity textures. OpenCraft doesn't ship those: the repo holds same-size placeholders
// named "gametex.<path>.png" (see OpenCraft/branding/make_game_texture_placeholders.py).
// When the lobby loads, this swaps each placeholder for the real texture, read from the
// newest game jar the launcher has downloaded. Before any version is installed, the
// placeholders (flat average colours) stay in place.

using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using UnityEngine;

namespace OpenCraft
{
    public static class GameTextureLoader
    {
        const string Prefix = "gametex.";
        const string TextureRoot = "assets/minecraft/textures/";

        // Textures the game has moved or renamed since the lobby was exported.
        static readonly Dictionary<string, string[]> Renamed = new Dictionary<string, string[]>
        {
            { "block/chain", new[] { "block/iron_chain" } },
            { "entity/cat/cat", new[] { "entity/cat/tabby", "entity/cat/cat_tabby" } },
            { "entity/banner_base", new[] { "entity/banner/base" } },
        };

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void LoadIntoScene()
        {
            string jar = FindNewestGameJar();
            if (jar == null)
            {
                Debug.Log("OpenCraft: no game installed yet, lobby keeps placeholder textures");
                return;
            }

            int swapped = 0, missing = 0;
            var loaded = new Dictionary<string, Texture2D>();
            using (var zip = new ZipArchive(File.OpenRead(jar), ZipArchiveMode.Read))
            {
                foreach (var renderer in Object.FindObjectsOfType<Renderer>(true))
                {
                    foreach (var material in renderer.sharedMaterials)
                    {
                        if (material == null) continue;
                        foreach (int id in material.GetTexturePropertyNameIDs())
                        {
                            var current = material.GetTexture(id);
                            if (current == null || !current.name.StartsWith(Prefix)) continue;

                            if (!loaded.TryGetValue(current.name, out var real))
                            {
                                real = ReadTexture(zip, current.name.Substring(Prefix.Length).Replace('.', '/'), current);
                                loaded[current.name] = real;
                                if (real == null) missing++;
                            }
                            if (real != null)
                            {
                                material.SetTexture(id, real);
                                swapped++;
                            }
                        }
                    }
                }
            }
            Debug.Log($"OpenCraft: lobby textures from {Path.GetFileName(Path.GetDirectoryName(jar))}: " +
                      $"{loaded.Count - missing} loaded, {missing} not found, {swapped} material slots updated");
        }

        static Texture2D ReadTexture(ZipArchive zip, string gamePath, Texture placeholder)
        {
            var candidates = new List<string> { gamePath };
            if (Renamed.TryGetValue(gamePath, out var alternatives)) candidates.AddRange(alternatives);
            if (gamePath.StartsWith("block/")) candidates.Add("item/" + gamePath.Substring("block/".Length));

            foreach (var path in candidates)
            {
                var entry = zip.GetEntry(TextureRoot + path + ".png");
                if (entry == null) continue;
                byte[] bytes;
                using (var stream = entry.Open())
                using (var buffer = new MemoryStream())
                {
                    stream.CopyTo(buffer);
                    bytes = buffer.ToArray();
                }
                var texture = new Texture2D(2, 2, TextureFormat.RGBA32, false)
                {
                    name = placeholder.name,
                    filterMode = FilterMode.Point,
                    wrapMode = placeholder.wrapMode,
                };
                if (texture.LoadImage(bytes)) return texture;
            }
            return null;
        }

        // The launcher keeps versions in <app files>/versions/<id>/client.jar.
        static string FindNewestGameJar()
        {
            var versions = Path.Combine(Application.persistentDataPath, "versions");
            if (!Directory.Exists(versions)) return null;
            string newest = null;
            var newestTime = System.DateTime.MinValue;
            foreach (var dir in Directory.GetDirectories(versions))
            {
                var jar = Path.Combine(dir, "client.jar");
                if (!File.Exists(jar)) continue;
                var time = File.GetLastWriteTimeUtc(jar);
                if (time > newestTime) { newest = jar; newestTime = time; }
            }
            return newest;
        }
    }
}

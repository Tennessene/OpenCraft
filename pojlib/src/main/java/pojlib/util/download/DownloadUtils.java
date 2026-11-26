// Modified for OpenCraft (2026-11-26): downloads identify themselves as OpenCraft; "bundled:" links install files shipped in the APK.
package pojlib.util.download;

import org.apache.commons.codec.binary.Hex;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.IOUtils;

import pojlib.API;
import pojlib.util.Logger;

import javax.net.ssl.SSLException;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;
import java.util.Objects;
import javax.annotation.Nullable;

public class DownloadUtils {
    private static void download(URL url, OutputStream os, long size) throws IOException {
        final int MAX_RETRIES = 3;
        int attempts = 0;

        while (true) {
            try {
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestProperty("User-Agent", "OpenCraft (+https://github.com/Tennessene/OpenCraft)");
                conn.setConnectTimeout(10000);
                conn.setDoInput(true);
                conn.connect();

                if (conn.getResponseCode() == HttpURLConnection.HTTP_OK) {
                    if(size == -1) {
                        size = conn.getContentLengthLong();
                    }

                    try (InputStream is = new StreamDL(conn.getInputStream(), size)) {
                        IOUtils.copy(is, os);
                    }
                    return;
                }
            } catch (IOException e) {
                if (++attempts >= MAX_RETRIES || e instanceof SSLException) {
                    throw new IOException("Unable to download from " + url, e);
                }
            }
        }
    }

    public static void downloadFile(String url, File out) throws IOException {
        downloadFile(url, out, -1);
    }

    // OpenCraft: links written as "bundled:<name>" are copied from the APK's assets/bundled/<name>
    // instead of being downloaded, so a build can ship a file (like its own Vivecraft) without hosting it.
    public static final String BUNDLED_PREFIX = "bundled:";

    public static void downloadFile(String url, File out, long size) throws IOException {
        Objects.requireNonNull(out.getParentFile()).mkdirs();
        if (url.startsWith(BUNDLED_PREFIX)) {
            String asset = "bundled/" + url.substring(BUNDLED_PREFIX.length());
            if (pojlib.util.Constants.APP_CONTEXT == null) throw new IOException("App context not set; cannot read " + asset);
            File part = File.createTempFile(out.getName(), ".part", out.getParentFile());
            try (InputStream in = pojlib.util.Constants.APP_CONTEXT.getAssets().open(asset);
                 OutputStream os = new BufferedOutputStream(Files.newOutputStream(part.toPath()))) {
                IOUtils.copy(in, os);
            } catch (IOException e) {
                part.delete();
                throw e;
            }
            if (!part.renameTo(out)) { part.delete(); throw new IOException("Could not move " + asset + " into place"); }
            Logger.getInstance().appendToLog("Installed bundled file " + asset);
            return;
        }
        File tempOut = File.createTempFile(out.getName(), ".part", out.getParentFile());
        try {
            try (OutputStream bos2 = new BufferedOutputStream(Files.newOutputStream(tempOut.toPath()))) {
                download(new URL(url), bos2, size);
                tempOut.renameTo(out);
                bos2.close();
                if (tempOut.exists()) tempOut.delete();
            } catch (IOException th2) {
                if (tempOut.exists()) tempOut.delete();
                throw th2;
            }
        } catch (IOException e) {
            if (tempOut.exists()) tempOut.delete();
            throw e;
        }
    }

    public static boolean compareSHA1(File f, @Nullable String sourceSHA) {
        try {
            String sha1_dst;
            try (InputStream is = Files.newInputStream(f.toPath())) {
                sha1_dst = new String(Hex.encodeHex(DigestUtils.sha1(is)));
            }
            if (sourceSHA != null) return sha1_dst.equalsIgnoreCase(sourceSHA);
            else return true; // No hash provided

        } catch (IOException e) {
            Logger.getInstance().appendToLog("Issue while comparing SHA1: " + e);
            return false;
        }
    }
}

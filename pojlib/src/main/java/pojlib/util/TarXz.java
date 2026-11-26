// Added for OpenCraft (2026-11-26). Original file, not derived from upstream Pojlib.
package pojlib.util;

import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream;
import org.apache.commons.compress.compressors.xz.XZCompressorInputStream;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;

/** Unpacks .tar.xz archives, such as the Java 25 runtime, keeping executable bits and symlinks. */
public final class TarXz {
    private TarXz() {}

    public static void extract(File archive, File destination) throws IOException {
        String root = destination.getCanonicalPath() + File.separator;
        try (InputStream raw = new BufferedInputStream(new FileInputStream(archive));
             TarArchiveInputStream tar = new TarArchiveInputStream(new XZCompressorInputStream(raw))) {
            TarArchiveEntry entry;
            byte[] buffer = new byte[64 * 1024];
            while ((entry = tar.getNextTarEntry()) != null) {
                File out = new File(destination, entry.getName());
                // refuse entries that would land outside the destination folder
                if (!(out.getCanonicalPath() + File.separator).startsWith(root) && !out.getCanonicalPath().equals(destination.getCanonicalPath())) {
                    throw new IOException("Archive entry escapes target folder: " + entry.getName());
                }
                if (entry.isDirectory()) {
                    out.mkdirs();
                } else if (entry.isSymbolicLink()) {
                    out.getParentFile().mkdirs();
                    out.delete();
                    Files.createSymbolicLink(out.toPath(), new File(entry.getLinkName()).toPath());
                } else {
                    out.getParentFile().mkdirs();
                    try (OutputStream os = new FileOutputStream(out)) {
                        int n;
                        while ((n = tar.read(buffer)) != -1) os.write(buffer, 0, n);
                    }
                    if ((entry.getMode() & 0111) != 0) out.setExecutable(true, false);
                    out.setReadable(true, false);
                }
            }
        }
    }
}

package com.jf.flycam;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.OpenableColumns;
import android.text.TextUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * 分享固件文件处理工具
 * 将第三方 App 分享的 uri 解析并复制到 App 内固件接收目录
 * （getExternalFilesDir + upgrade_receive_files），
 * 与 Flutter 层 kDirectoryPath + upgrade_receive_files 保持一致。
 */
public class ReceiveFileUtils {

    /**
     * 固件接收目录
     */
    static File receiveDir(Context context) {
        File dir = new File(context.getExternalFilesDir(null), "upgrade_receive_files");
        if (!dir.exists()) {
            // noinspection ResultOfMethodCallIgnored
            dir.mkdirs();
        }
        return dir;
    }

    /**
     * 解析分享的 uri 并复制到固件接收目录，返回复制后的文件路径
     * content scheme：通过 ContentResolver 流复制（Android 10+ 及部分文件管理器）
     * file scheme：直接定位源文件后复制
     *
     * @return 复制成功返回目标路径，失败返回 null
     */
    static String resolveToReceiveFile(Context context, Uri uri) {
        if (uri == null) {
            return null;
        }
        String scheme = uri.getScheme();
        if (TextUtils.isEmpty(scheme)) {
            return null;
        }
        File receiveDir = receiveDir(context);
        try {
            if ("file".equalsIgnoreCase(scheme)) {
                return copyByPath(uri.getPath(), receiveDir);
            } else if ("content".equalsIgnoreCase(scheme)) {
                return copyByContentResolver(context, uri, receiveDir);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 复制文件
     */
    static boolean copyFile(String oldPath, String newPath) {
        try (InputStream inStream = new FileInputStream(oldPath);
                OutputStream outStream = new FileOutputStream(newPath)) {
            byte[] buffer = new byte[1024 * 8];
            int bytesRead;
            while ((bytesRead = inStream.read(buffer)) != -1) {
                outStream.write(buffer, 0, bytesRead);
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * file scheme：直接复制源文件到接收目录
     */
    private static String copyByPath(String sourcePath, File receiveDir) {
        if (TextUtils.isEmpty(sourcePath)) {
            return null;
        }
        File sourceFile = new File(sourcePath);
        if (!sourceFile.exists()) {
            return null;
        }
        File targetFile = new File(receiveDir, sourceFile.getName());
        return copyFile(sourcePath, targetFile.getAbsolutePath()) ? targetFile.getAbsolutePath() : null;
    }

    /**
     * content scheme：通过 ContentResolver 流复制到接收目录
     */
    private static String copyByContentResolver(Context context, Uri uri, File receiveDir) {
        ContentResolver resolver = context.getContentResolver();
        String fileName = null;
        try (Cursor cursor = resolver.query(uri, null, null, null, null)) {
            if (cursor != null && cursor.moveToFirst()) {
                int index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                if (index >= 0) {
                    fileName = cursor.getString(index);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (TextUtils.isEmpty(fileName)) {
            fileName = "firmware_" + System.currentTimeMillis() + ".bin";
        }
        File targetFile = new File(receiveDir, fileName);
        try (InputStream inStream = resolver.openInputStream(uri);
                OutputStream outStream = new FileOutputStream(targetFile)) {
            if (inStream == null) {
                return null;
            }
            byte[] buffer = new byte[1024 * 8];
            int bytesRead;
            while ((bytesRead = inStream.read(buffer)) != -1) {
                outStream.write(buffer, 0, bytesRead);
            }
            return targetFile.getAbsolutePath();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}

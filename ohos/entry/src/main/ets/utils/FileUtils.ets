import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';

/**
 * 分享固件文件处理工具
 * 将系统分享面板传入的文件复制到 App 内固件接收目录
 * （filesDir + upgrade_receive_files），
 * 与 Flutter 层 kDirectoryPath + upgrade_receive_files 保持一致。
 */
export class FileUtils {

  /**
   * 处理共享文件：校验 .bin/.img 合法性后复制到固件接收目录
   * @param context 上下文
   * @param url 文件 uri
   * @returns 复制成功返回 true，文件类型不合法返回 false
   */
  static handleSharedFile(context: common.Context, url: string): boolean {
    // 提取文件名
    const fileName = FileUtils.extractFileName(url);
    // 检查文件合法性
    if (!FileUtils.isFileLegal(fileName)) {
      return false;
    }
    // 获取 filesDir 目录路径（与 Flutter 层 xcGetOhosFilesDir 一致）
    const documentPath = context.getApplicationContext().filesDir;
    const filePath = `${documentPath}/upgrade_receive_files`;
    FileUtils.createDirectory(filePath);

    // 检查文件是否已存在，如果存在则删除
    if (FileUtils.fileExists(filePath, fileName)) {
      FileUtils.deleteFile(filePath, fileName);
    }

    FileUtils.copyFile(url, `${filePath}/${fileName}`);
    return true;
  }

  /**
   * 从 URL 中提取文件名
   */
  static extractFileName(url: string): string {
    const lastSlashIndex = url.lastIndexOf('/');
    if (lastSlashIndex !== -1) {
      return url.substring(lastSlashIndex + 1);
    }
    return url;
  }

  /**
   * 创建目录
   */
  static createDirectory(path: string): void {
    try {
      fs.mkdirSync(path);
    } catch (err) {
      // 目录已存在时忽略
    }
  }

  /**
   * 检查文件是否已存在
   */
  private static fileExists(directory: string, fileName: string): boolean {
    const filePath = `${directory}/${fileName}`;
    try {
      const stats = fs.statSync(filePath);
      return stats.isFile();
    } catch (err) {
      return false;
    }
  }

  /**
   * 删除文件
   */
  private static deleteFile(directory: string, fileName: string): void {
    const filePath = `${directory}/${fileName}`;
    try {
      fs.unlinkSync(filePath);
    } catch (err) {
      console.error(`Failed to delete file = ${filePath}, error = ${err.message}`);
    }
  }

  /**
   * 检查文件合法性：.bin/.img 结尾合法
   */
  private static isFileLegal(fileName: string): boolean {
    return fileName.endsWith('.bin') || fileName.endsWith('.img');
  }

  /**
   * 复制文件
   */
  private static copyFile(sourcePath: string, destPath: string): void {
    try {
      let file = fs.openSync(sourcePath, fs.OpenMode.READ_ONLY)
      let file2 = fs.openSync(destPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      fs.copyFileSync(file.fd, file2.fd);
      fs.closeSync(file);
      fs.closeSync(file2);
    } catch (err) {
      console.error(`Failed to copy file, error = ${err.message}`);
    }
  }
}

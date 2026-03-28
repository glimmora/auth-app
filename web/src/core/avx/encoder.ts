import JSZip from 'jszip';
import { saveAs } from 'file-saver';
import { encryptPacked, decryptPacked, deriveKey, generateSalt } from '../crypto/aes-gcm';

export interface AVXManifest {
  format: 'avx';
  version: string;
  app: string;
  platform: 'flutter' | 'web';
  created_at: string;
  account_count: number;
  kdf: string;
  kdf_iterations: number;
  kdf_hash: string;
  salt: string;
  iv: string;
  encryption: string;
}

export interface AVXData {
  accounts: Array<{
    uuid: string;
    type: string;
    issuer: string;
    label: string;
    secret: string;
    algorithm: string;
    digits: number;
    period: number;
    counter: number;
    time_offset: number;
    group_uuid?: string;
    icon?: string;
    icon_custom_b64?: string;
    sort_order: number;
    favorite: boolean;
    created_at: string;
    updated_at: string;
  }>;
  groups: Array<{
    uuid: string;
    name: string;
    color: string;
    sort_order: number;
  }>;
  settings: {
    global_time_offset: number;
    theme: string;
    tap_to_reveal: boolean;
  };
}

/**
 * Export vault to AVX format
 */
export async function exportToAVX(
  data: AVXData,
  password: string
): Promise<Blob> {
  const salt = generateSalt(32);
  const key = await deriveKey(password, salt, 310000);

  // Encrypt data
  const encoder = new TextEncoder();
  const plaintext = encoder.encode(JSON.stringify(data));
  const encrypted = await encryptPacked(plaintext, key);

  // Create manifest
  const manifest: AVXManifest = {
    format: 'avx',
    version: '1.0.0',
    app: 'AuthVault',
    platform: 'web',
    created_at: new Date().toISOString(),
    account_count: data.accounts.length,
    kdf: 'PBKDF2',
    kdf_iterations: 310000,
    kdf_hash: 'SHA-256',
    salt: bufferToBase64(salt.buffer as ArrayBuffer),
    iv: bufferToBase64(encrypted.slice(0, 12).buffer as ArrayBuffer),
    encryption: 'AES-256-GCM',
  };

  // Create ZIP
  const zip = new JSZip();
  zip.file('manifest.json', JSON.stringify(manifest, null, 2));
  zip.file('data.enc', encrypted);

  // Generate and download
  const content = await zip.generateAsync({ type: 'blob' });
  saveAs(content, 'authvault_backup.avx');

  return content;
}

/**
 * Import vault from AVX format
 */
export async function importFromAVX(
  file: File,
  password: string
): Promise<AVXData> {
  // Read file
  const arrayBuffer = await file.arrayBuffer();

  // Extract ZIP
  const zip = await JSZip.loadAsync(arrayBuffer);

  // Read manifest
  const manifestFile = zip.file('manifest.json');
  if (!manifestFile) {
    throw new Error('Invalid AVX file: missing manifest.json');
  }
  const manifestText = await manifestFile.async('text');
  const manifest = JSON.parse(manifestText) as AVXManifest;

  // Validate manifest
  if (manifest.format !== 'avx') {
    throw new Error('Invalid AVX file format');
  }

  // Read encrypted data
  const dataFile = zip.file('data.enc');
  if (!dataFile) {
    throw new Error('Invalid AVX file: missing data.enc');
  }
  const encryptedData = await dataFile.async('uint8array');

  // Derive key
  const salt = base64ToArrayBuffer(manifest.salt);
  const key = await deriveKey(password, new Uint8Array(salt), manifest.kdf_iterations);

  // Decrypt data
  const decrypted = await decryptPacked(encryptedData, key);
  const decoder = new TextDecoder();
  const jsonText = decoder.decode(decrypted);

  return JSON.parse(jsonText) as AVXData;
}

function bufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary);
}

function base64ToArrayBuffer(base64: string): ArrayBuffer {
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer as ArrayBuffer;
}

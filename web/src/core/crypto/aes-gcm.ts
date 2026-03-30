/**
 * AES-256-GCM encryption/decryption using Web Crypto API
 */

export interface EncryptedData {
  iv: string;
  ciphertext: string;
  tag: string;
}

/**
 * Encrypt plaintext using AES-256-GCM
 */
export async function encrypt(
  plaintext: Uint8Array,
  key: CryptoKey
): Promise<EncryptedData> {
  // Generate random 96-bit IV
  const iv = crypto.getRandomValues(new Uint8Array(12));

  // Encrypt
  const result = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv },
    key,
    plaintext as unknown as ArrayBuffer
  );

  // Extract ciphertext and tag (tag is last 16 bytes)
  const ciphertextArray = new Uint8Array(result);
  const ciphertext = ciphertextArray.slice(0, -16);
  const tag = ciphertextArray.slice(-16);

  return {
    iv: bufferToBase64(iv.buffer as ArrayBuffer),
    ciphertext: bufferToBase64(ciphertext.buffer as ArrayBuffer),
    tag: bufferToBase64(tag.buffer as ArrayBuffer),
  };
}

/**
 * Decrypt ciphertext using AES-256-GCM
 */
export async function decrypt(
  encrypted: EncryptedData,
  key: CryptoKey
): Promise<Uint8Array> {
  const iv = base64ToBuffer(encrypted.iv);
  const ciphertext = base64ToBuffer(encrypted.ciphertext);
  const tag = base64ToBuffer(encrypted.tag);

  // Combine ciphertext and tag
  const combined = new Uint8Array(ciphertext.length + tag.length);
  combined.set(ciphertext, 0);
  combined.set(tag, ciphertext.length);

  const result = await crypto.subtle.decrypt(
    { name: 'AES-GCM', iv: iv as unknown as ArrayBuffer },
    key,
    combined as unknown as ArrayBuffer
  );

  return new Uint8Array(result);
}

/**
 * Encrypt and return packed buffer (IV + ciphertext + tag)
 */
export async function encryptPacked(
  plaintext: Uint8Array,
  key: CryptoKey
): Promise<Uint8Array> {
  const encrypted = await encrypt(plaintext, key);

  const iv = base64ToBuffer(encrypted.iv);
  const ciphertext = base64ToBuffer(encrypted.ciphertext);
  const tag = base64ToBuffer(encrypted.tag);

  const packed = new Uint8Array(iv.length + ciphertext.length + tag.length);
  packed.set(iv, 0);
  packed.set(ciphertext, iv.length);
  packed.set(tag, iv.length + ciphertext.length);

  return packed;
}

/**
 * Decrypt from packed buffer (IV + ciphertext + tag)
 */
export async function decryptPacked(
  packed: Uint8Array,
  key: CryptoKey
): Promise<Uint8Array> {
  // Unpack: IV (12 bytes) + ciphertext + tag (16 bytes)
  const iv = packed.slice(0, 12);
  const tag = packed.slice(-16);
  const ciphertext = packed.slice(12, -16);

  // Web Crypto expects ciphertext + tag combined
  const combined = new Uint8Array(ciphertext.length + tag.length);
  combined.set(ciphertext, 0);
  combined.set(tag, ciphertext.length);

  const result = await crypto.subtle.decrypt(
    { name: 'AES-GCM', iv: new Uint8Array(iv) },
    key,
    combined as unknown as ArrayBuffer
  );

  return new Uint8Array(result);
}

/**
 * Generate a random 256-bit key
 */
export async function generateKey(): Promise<CryptoKey> {
  return await crypto.subtle.generateKey(
    { name: 'AES-GCM', length: 256 },
    true,
    ['encrypt', 'decrypt']
  );
}

/**
 * Import key from raw bytes
 */
export async function importKey(keyData: Uint8Array): Promise<CryptoKey> {
  return await crypto.subtle.importKey(
    'raw',
    keyData as unknown as ArrayBuffer,
    { name: 'AES-GCM' },
    false,
    ['encrypt', 'decrypt']
  );
}

/**
 * Export key to raw bytes
 */
export async function exportKey(key: CryptoKey): Promise<Uint8Array> {
  const exported = await crypto.subtle.exportKey('raw', key);
  return new Uint8Array(exported);
}

/**
 * Derive key from password using PBKDF2
 */
export async function deriveKey(
  password: string,
  salt: Uint8Array,
  iterations: number = 310000
): Promise<CryptoKey> {
  const enc = new TextEncoder();
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    enc.encode(password),
    { name: 'PBKDF2' },
    false,
    ['deriveKey']
  );

  return await crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt: salt as unknown as ArrayBuffer,
      iterations,
      hash: 'SHA-256',
    },
    keyMaterial,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt']
  );
}

/**
 * Generate random salt
 */
export function generateSalt(length: number = 32): Uint8Array {
  return crypto.getRandomValues(new Uint8Array(length));
}

/**
 * Convert ArrayBuffer to Base64
 */
function bufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary);
}

/**
 * Convert Base64 to Uint8Array
 */
function base64ToBuffer(base64: string): Uint8Array {
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

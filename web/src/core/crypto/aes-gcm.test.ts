import { describe, it, expect } from 'vitest';
import {
  encrypt,
  decrypt,
  encryptPacked,
  decryptPacked,
  generateKey,
  importKey,
  exportKey,
  deriveKey,
  generateSalt,
} from '@/core/crypto/aes-gcm';

describe('AES-256-GCM', () => {
  it('generates a 256-bit key', async () => {
    const key = await generateKey();
    expect(key).toBeDefined();
    expect(key.type).toBe('secret');
    expect(key.algorithm).toMatchObject({ name: 'AES-GCM', length: 256 });
  });

  it('encrypts and decrypts data', async () => {
    const key = await generateKey();
    const plaintext = new TextEncoder().encode('Hello, AuthVault!');
    const encrypted = await encrypt(plaintext, key);

    expect(encrypted.iv).toBeDefined();
    expect(encrypted.ciphertext).toBeDefined();
    expect(encrypted.tag).toBeDefined();

    const decrypted = await decrypt(encrypted, key);
    const decryptedText = new TextDecoder().decode(decrypted);
    expect(decryptedText).toBe('Hello, AuthVault!');
  });

  it('produces different IVs for each encryption', async () => {
    const key = await generateKey();
    const plaintext = new TextEncoder().encode('same data');

    const enc1 = await encrypt(plaintext, key);
    const enc2 = await encrypt(plaintext, key);

    expect(enc1.iv).not.toBe(enc2.iv);
    expect(enc1.ciphertext).not.toBe(enc2.ciphertext);
  });

  it('fails to decrypt with wrong key', async () => {
    const key1 = await generateKey();
    const key2 = await generateKey();
    const plaintext = new TextEncoder().encode('secret');

    const encrypted = await encrypt(plaintext, key1);

    await expect(decrypt(encrypted, key2)).rejects.toThrow();
  });

  it('encryptPacked and decryptPacked round-trip', async () => {
    const key = await generateKey();
    const plaintext = new TextEncoder().encode('packed data test');
    const packed = await encryptPacked(plaintext, key);

    expect(packed.length).toBeGreaterThan(plaintext.length);

    const decrypted = await decryptPacked(packed, key);
    const decryptedText = new TextDecoder().decode(decrypted);
    expect(decryptedText).toBe('packed data test');
  });

  it('imports and exports key', async () => {
    const key = await generateKey();
    const exported = await exportKey(key);

    expect(exported).toBeInstanceOf(Uint8Array);
    expect(exported.length).toBe(32); // 256 bits

    const imported = await importKey(exported);
    expect(imported).toBeDefined();
    expect(imported.algorithm).toMatchObject({ name: 'AES-GCM', length: 256 });
  });

  it('encrypts with imported key', async () => {
    const key1 = await generateKey();
    const exported = await exportKey(key1);
    const key2 = await importKey(exported);

    const plaintext = new TextEncoder().encode('cross-key test');
    const encrypted = await encrypt(plaintext, key1);
    const decrypted = await decrypt(encrypted, key2);

    expect(new TextDecoder().decode(decrypted)).toBe('cross-key test');
  });

  it('derives key from password with PBKDF2', async () => {
    const password = 'mySecurePassword123';
    const salt = generateSalt(32);

    const key = await deriveKey(password, salt, 10000);
    expect(key).toBeDefined();
    expect(key.algorithm).toMatchObject({ name: 'AES-GCM', length: 256 });
  });

  it('derives same key from same password and salt', async () => {
    const password = 'testPassword';
    const salt = generateSalt(32);

    const key1 = await deriveKey(password, salt, 10000);
    const key2 = await deriveKey(password, salt, 10000);

    const plaintext = new TextEncoder().encode('consistent key');
    const encrypted = await encrypt(plaintext, key1);
    const decrypted = await decrypt(encrypted, key2);

    expect(new TextDecoder().decode(decrypted)).toBe('consistent key');
  });

  it('derives different keys from different salts', async () => {
    const password = 'samePassword';
    const salt1 = generateSalt(32);
    const salt2 = generateSalt(32);

    const key1 = await deriveKey(password, salt1, 10000);
    const key2 = await deriveKey(password, salt2, 10000);

    const plaintext = new TextEncoder().encode('different salts');
    const encrypted = await encrypt(plaintext, key1);

    await expect(decrypt(encrypted, key2)).rejects.toThrow();
  });

  it('generates salt of correct length', () => {
    const salt16 = generateSalt(16);
    const salt32 = generateSalt(32);
    const salt64 = generateSalt(64);

    expect(salt16.length).toBe(16);
    expect(salt32.length).toBe(32);
    expect(salt64.length).toBe(64);
  });

  it('generates random salt each time', () => {
    const salt1 = generateSalt(32);
    const salt2 = generateSalt(32);

    expect(salt1).not.toEqual(salt2);
  });

  it('handles empty plaintext', async () => {
    const key = await generateKey();
    const plaintext = new Uint8Array(0);
    const encrypted = await encrypt(plaintext, key);
    const decrypted = await decrypt(encrypted, key);

    expect(decrypted.length).toBe(0);
  });

  it('handles medium-sized plaintext', async () => {
    const key = await generateKey();
    const plaintext = new Uint8Array(1024);
    crypto.getRandomValues(plaintext);

    const encrypted = await encryptPacked(plaintext, key);
    const decrypted = await decryptPacked(encrypted, key);

    expect(decrypted).toEqual(plaintext);
  });
});

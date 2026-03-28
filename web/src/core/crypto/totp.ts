import { HmacSHA1, HmacSHA256, HmacSHA512, enc } from 'crypto-js';

export type OTPAlgorithm = 'SHA1' | 'SHA256' | 'SHA512';

export interface TOTPOptions {
  secret: string;
  digits?: number;
  period?: number;
  algorithm?: OTPAlgorithm;
  offset?: number;
}

/**
 * TOTP Engine - RFC 6238 implementation
 */
export function generateTOTP(options: TOTPOptions): string {
  const {
    secret,
    digits = 6,
    period = 30,
    algorithm = 'SHA1',
    offset = 0,
  } = options;

  const adjustedTime = Math.floor(Date.now() / 1000) + offset;
  const counter = Math.floor(adjustedTime / period);

  return computeHOTP({
    secret,
    counter,
    digits,
    algorithm,
  });
}

/**
 * Get next TOTP code (for preview)
 */
export function getNextTOTP(options: TOTPOptions): string {
  const {
    secret,
    digits = 6,
    period = 30,
    algorithm = 'SHA1',
    offset = 0,
  } = options;

  const adjustedTime = Math.floor(Date.now() / 1000) + offset;
  const counter = Math.floor(adjustedTime / period) + 1;

  return computeHOTP({
    secret,
    counter,
    digits,
    algorithm,
  });
}

/**
 * Get seconds remaining in current period
 */
export function getRemainingSeconds(period: number = 30, offset: number = 0): number {
  const adjustedTime = Math.floor(Date.now() / 1000) + offset;
  return period - (adjustedTime % period);
}

/**
 * Get progress (0.0 to 1.0) through current period
 */
export function getPeriodProgress(period: number = 30, offset: number = 0): number {
  const adjustedTime = Math.floor(Date.now() / 1000) + offset;
  return (adjustedTime % period) / period;
}

interface HOTPOptions {
  secret: string;
  counter: number;
  digits?: number;
  algorithm?: OTPAlgorithm;
}

/**
 * HOTP Engine - RFC 4226 implementation
 */
function computeHOTP(options: HOTPOptions): string {
  const {
    secret,
    counter,
    digits = 6,
    algorithm = 'SHA1',
  } = options;

  // Decode base32 secret
  const key = base32Decode(secret.toUpperCase().replace(/=/g, '').replace(/\s/g, ''));

  // Create counter bytes (big-endian 8 bytes)
  const counterBytes = new Uint8Array(8);
  let c = counter;
  for (let i = 7; i >= 0; i--) {
    counterBytes[i] = c & 0xff;
    c = Math.floor(c / 256);
  }

  // Compute HMAC using crypto-js
  const keyHex = bytesToHex(key);
  const hash = getHmac(algorithm, keyHex);

  // Dynamic truncation (RFC 4226)
  const hashBytes = hexToBytes(hash);
  const offset = hashBytes[hashBytes.length - 1] & 0x0f;
  let binaryCode = 0;
  for (let i = 0; i < 4; i++) {
    binaryCode = (binaryCode << 8) | (hashBytes[offset + i] & 0xff);
  }
  binaryCode &= 0x7fffffff;

  // Generate OTP
  const otp = binaryCode % Math.pow(10, digits);

  // Pad with leading zeros
  return otp.toString().padStart(digits, '0');
}

function getHmac(algorithm: OTPAlgorithm, keyHex: string): string {
  const key = enc.Hex.parse(keyHex);

  switch (algorithm) {
    case 'SHA256':
      // @ts-ignore - crypto-js API
      return HmacSHA256('', key).toString();
    case 'SHA512':
      // @ts-ignore - crypto-js API
      return HmacSHA512('', key).toString();
    case 'SHA1':
    default:
      // @ts-ignore - crypto-js API
      return HmacSHA1('', key).toString();
  }
}

function base32Decode(input: string): Uint8Array {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  const buffer: number[] = [];
  let bufferValue = 0;
  let bitsLeft = 0;

  for (const char of input) {
    const index = alphabet.indexOf(char);
    if (index === -1) continue;

    bufferValue = (bufferValue << 5) | index;
    bitsLeft += 5;

    if (bitsLeft >= 8) {
      buffer.push((bufferValue >> (bitsLeft - 8)) & 0xff);
      bitsLeft -= 8;
    }
  }

  return new Uint8Array(buffer);
}

function bytesToHex(bytes: Uint8Array): string {
  return Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');
}

function hexToBytes(hex: string): Uint8Array {
  const bytes: number[] = [];
  for (let i = 0; i < hex.length; i += 2) {
    bytes.push(parseInt(hex.substr(i, 2), 16));
  }
  return new Uint8Array(bytes);
}

/**
 * Generate random base32 secret
 */
export function generateSecret(bytes: number = 20): string {
  const array = new Uint8Array(bytes);
  crypto.getRandomValues(array);

  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  let result = '';

  for (const byte of array) {
    result += alphabet[byte % alphabet.length];
  }

  return result;
}

declare module 'crypto-js' {
  export class HmacSHA1 {
    constructor(message: string, key: string);
    finalize(): { toString(): string; length: number };
  }
  export class HmacSHA256 {
    constructor(message: string, key: string);
    finalize(): { toString(): string; length: number };
  }
  export class HmacSHA512 {
    constructor(message: string, key: string);
    finalize(): { toString(): string; length: number };
  }
  export const enc: {
    Hex: {
      stringify(bytes: number[]): string;
      parse(hex: string): { words: number[]; sigBytes: number };
    };
    Latin1: {
      parse(str: string): { words: number[]; sigBytes: number };
    };
  };
}

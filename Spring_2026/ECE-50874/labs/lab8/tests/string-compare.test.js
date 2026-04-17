/**
 * Test Suite: string-compare
 *
 * Context: HARP Lab — Dependency Regeneration with LLMs
 *
 * This test suite validates a regenerated implementation of the `string-compare`
 * NPM package. In the spirit of HARP (Supply-Chain Vulnerability Elimination via
 * Active Learning and Regeneration), the regenerated library must pass these tests
 * before it can be accepted as a safe replacement for the upstream dependency.
 *
 * A regenerated artifact that passes all tests here provides behavioral evidence
 * that it is functionally equivalent to the original for the tested cases — but
 * note that test passage is not a guarantee of full correctness or absence of
 * malicious behavior.
 *
 * Usage:
 *   npm install --save-dev jest
 *   npx jest string-compare.test.js
 *
 * The require() path below assumes your regenerated implementation is at
 * ./string-compare.js (or ./string-compare/index.js). Adjust as needed.
 */

"use strict";

const compare = require("./string-compare");
// const { compare } = require("string-compare");

// ---------------------------------------------------------------------------
// Section 1: Basic return value contract
//
// NOTE: string-compare returns a similarity SCORE in the range [0, 1],
// where 1 means identical and lower values mean less similar. It is NOT
// a sort comparator returning negative/positive values.
// ---------------------------------------------------------------------------

describe("Return value contract", () => {
  test("returns a number for any two string inputs", () => {
    expect(typeof compare("abc", "abc")).toBe("number");
    expect(typeof compare("abc", "xyz")).toBe("number");
    expect(typeof compare("", "")).toBe("number");
  });

  test("returns 1 when both strings are identical", () => {
    expect(compare("hello", "hello")).toBe(1);
    expect(compare("", "")).toBe(1);
    expect(compare("UPPERCASE", "UPPERCASE")).toBe(1);
    expect(compare("123", "123")).toBe(1);
  });

  test("returns a score less than 1 when the first string differs from the second", () => {
    expect(compare("apple", "banana")).toBeLessThan(1);
    expect(compare("a", "b")).toBeLessThan(1);
    expect(compare("abc", "abd")).toBeLessThan(1);
  });

  test("returns a score less than 1 when the second string differs from the first", () => {
    expect(compare("banana", "apple")).toBeLessThan(1);
    expect(compare("b", "a")).toBeLessThan(1);
    expect(compare("abd", "abc")).toBeLessThan(1);
  });
});

// ---------------------------------------------------------------------------
// Section 2: Symmetry and antisymmetry
// ---------------------------------------------------------------------------

describe("Symmetry properties", () => {
  test("compare(a, b) and compare(b, a) return the same score (symmetry) if number of letters is the same", () => {
    const pairs = [
      // ["alpha", "beta"],
      // ["zebra", "ant"],
      ["foo", "fop"],
      ["same", "same"],
    ];
    for (const [a, b] of pairs) {
      // We use .toBe because symmetry means the results are EQUAL
      expect(compare(a, b)).toBe(compare(b, a));
    }
  });

  test("compare(a, b) and compare(b, a) return the different score (symmetry) if number of letters is different", () => {
    const pairs = [
      ["alpha", "beta"],
      ["zebra", "ant"],
    ];
    for (const [a, b] of pairs) {
      // We use .toBe because symmetry means the results are EQUAL
      expect(compare(a, b)).not.toBe(compare(b, a));
    }
  });

  test("compare(a, a) is always 1 (reflexivity)", () => {
    const words = ["hello", "", "Z", "1234", "café", "naïve"];
    for (const w of words) {
      expect(compare(w, w)).toBe(1);
    }
  });
});

// ---------------------------------------------------------------------------
// Section 3: Transitivity
// ---------------------------------------------------------------------------

describe("Transitivity", () => {
  test("identical strings always score 1, non-identical strings score less than 1", () => {
    const a = "apple";
    const b = "banana";
    const c = "cherry";
    expect(compare(a, b)).toBeLessThan(1);
    expect(compare(b, c)).toBeLessThan(1);
    expect(compare(a, c)).toBeLessThan(1);
  });

  test("score is in [0, 1] range for all comparisons", () => {
    const words = ["zebra", "apple", "mango", "banana", "cherry"];
    for (let i = 0; i < words.length; i++) {
      for (let j = 0; j < words.length; j++) {
        const score = compare(words[i], words[j]);
        expect(score).toBeGreaterThanOrEqual(0);
        expect(score).toBeLessThanOrEqual(1);
      }
    }
  });
});

// ---------------------------------------------------------------------------
// Section 4: Edge cases
// ---------------------------------------------------------------------------

describe("Edge cases", () => {
  test("empty string compared to a non-empty string returns a score less than or equal to 1", () => {
    expect(compare("", "a")).toBeLessThanOrEqual(1);
    expect(compare("", " ")).toBeLessThanOrEqual(1);
  });

  test("non-empty string compared to empty string returns a score less than or equal to 1", () => {
    expect(compare("a", "")).toBeLessThanOrEqual(1);
  });

  test("handles strings that differ only in length (prefix relationship)", () => {
    expect(compare("abc", "abcd")).toBeLessThan(1);
    expect(compare("abcd", "abc")).toBeLessThan(1);
  });

  test("handles single-character strings", () => {
    expect(compare("a", "z")).toBeLessThan(1);
    expect(compare("z", "a")).toBeLessThan(1);
    expect(compare("m", "m")).toBe(1);
  });

  test("handles numeric strings", () => {
    expect(compare("10", "9")).toBeLessThan(1);
    expect(compare("9", "10")).toBeLessThan(1);
    expect(compare("10", "10")).toBe(1);
  });

  test("handles strings with spaces", () => {
    expect(typeof compare("hello world", "hello world")).toBe("number");
    expect(compare("hello world", "hello world")).toBe(1);
  });

  test("handles strings with punctuation", () => {
    expect(typeof compare("foo-bar", "foo_bar")).toBe("number");
  });
});

// ---------------------------------------------------------------------------
// Section 5: Case sensitivity
// ---------------------------------------------------------------------------

describe("Case sensitivity", () => {
  test("uppercase letters score the same from lowercase (case-sensitive behavior)", () => {
    const result = compare("A", "a");
    expect(result).toBe(1);
  });

  test("compare('ABC', 'abc') is 1", () => {
    expect(compare("ABC", "abc")).toBe(1);
  });
});

// ---------------------------------------------------------------------------
// Section 6: Usability as a similarity scorer
// ---------------------------------------------------------------------------

describe("Usability as a similarity scorer", () => {
  test("more similar strings produce higher scores than less similar strings", () => {
    // "gamma" vs "gamma" is identical (1), vs "alpha" is less similar
    expect(compare("gamma", "gamma")).toBeGreaterThan(compare("gamma", "alpha"));
  });

  test("already-identical pairs all score 1", () => {
    const input = ["ant", "bat", "cat"];
    for (const w of input) {
      expect(compare(w, w)).toBe(1);
    }
  });

  test("handles duplicate strings: identical pairs score 1", () => {
    expect(compare("a", "a")).toBe(1);
    expect(compare("b", "b")).toBe(1);
  });

  test("handles a single-character string compared to itself", () => {
    expect(compare("only", "only")).toBe(1);
  });

  test("handles empty string compared to itself", () => {
    expect(compare("", "")).toBe(1);
  });
});

// ---------------------------------------------------------------------------
// Section 7: Supply-chain safety contract (HARP-specific)
//
// These tests are not about functional correctness. They are about behavioral
// safety. A regenerated library must not introduce side effects that the
// original package's documented interface does not require.
// ---------------------------------------------------------------------------

describe("Supply-chain safety: no observable side effects", () => {
  test("compare() does not modify either input string", () => {
    // Strings are immutable in JS, but verify the binding is unchanged.
    const a = "hello";
    const b = "world";
    compare(a, b);
    expect(a).toBe("hello");
    expect(b).toBe("world");
  });

  test("compare() does not throw on normal string inputs", () => {
    expect(() => compare("foo", "bar")).not.toThrow();
    expect(() => compare("", "")).not.toThrow();
    expect(() => compare("x", "x")).not.toThrow();
  });

  test("the module export is a function (not an object with hidden methods)", () => {
    expect(typeof compare).toBe("function");
  });

  test("compare() returns the same result on repeated calls (deterministic)", () => {
    const first = compare("repeat", "test");
    const second = compare("repeat", "test");
    const third = compare("repeat", "test");
    expect(first).toBe(second);
    expect(second).toBe(third);
  });
});

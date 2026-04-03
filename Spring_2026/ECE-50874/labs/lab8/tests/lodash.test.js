/**
 * Test Suite: lodash
 *
 * Context: HARP Lab — Dependency Regeneration with LLMs
 *
 * This test suite is used in two distinct phases of the take-home assignment:
 *
 *   Part 1 — Full Replication:
 *     Your regenerated lodash must pass ALL tests in this file.
 *     This represents the harder engineering goal: full behavioral equivalence.
 *
 *   Part 2 — Use-Case-Driven Projection:
 *     Your regenerated lodash must only pass the tests in the section labelled
 *     "DEMO application surface" (see bottom of file). This represents the
 *     HARP-style insight that you only need to replace what you actually use.
 *
 * In both cases, test passage is evidence of correctness — not proof.
 * Manual inspection remains a complementary, necessary activity.
 *
 * Usage:
 *   npm install --save-dev jest
 *   npx jest lodash.test.js
 *
 * The require() path below assumes your regenerated implementation is at
 * ./lodash.js (or ./lodash/index.js). Adjust as needed.
 */

"use strict";

// const lodash = require("./lodash"); // TODO: THIS TO POINT TO YOUR FILE (i.e., lodash.js) TO RUN THE TEST SUITE ON IT
const lodash = require("lodash");


// ===========================================================================
// PART 1: FULL REPLICATION TEST SUITE
//
// These tests cover the lodash surface area broadly. A full replication must
// pass all of them. A use-case-driven projection need not.
// ===========================================================================

// ---------------------------------------------------------------------------
// Array utilities
// ---------------------------------------------------------------------------

describe("lodash.chunk", () => {
  test("splits an array into chunks of a given size", () => {
    expect(lodash.chunk([1, 2, 3, 4, 5], 2)).toEqual([[1, 2], [3, 4], [5]]);
    expect(lodash.chunk([1, 2, 3, 4], 2)).toEqual([[1, 2], [3, 4]]);
  });

  test("returns empty array for empty input", () => {
    expect(lodash.chunk([], 2)).toEqual([]);
  });

  test("chunk size of 1 wraps each element", () => {
    expect(lodash.chunk([1, 2, 3], 1)).toEqual([[1], [2], [3]]);
  });
});

describe("lodash.compact", () => {
  test("removes falsy values", () => {
    expect(lodash.compact([0, 1, false, 2, "", 3, null, undefined, NaN])).toEqual([1, 2, 3]);
  });

  test("returns empty array if all values are falsy", () => {
    expect(lodash.compact([false, null, 0, "", undefined])).toEqual([]);
  });

  test("returns the same array if all values are truthy", () => {
    expect(lodash.compact([1, "a", true, {}])).toEqual([1, "a", true, {}]);
  });
});

describe("lodash.uniq", () => {
  test("removes duplicate primitives", () => {
    expect(lodash.uniq([1, 2, 1, 3, 2])).toEqual([1, 2, 3]);
  });

  test("preserves first occurrence", () => {
    expect(lodash.uniq(["a", "b", "a"])).toEqual(["a", "b"]);
  });

  test("works on an already-unique array", () => {
    expect(lodash.uniq([1, 2, 3])).toEqual([1, 2, 3]);
  });

  test("returns empty array for empty input", () => {
    expect(lodash.uniq([])).toEqual([]);
  });
});

describe("lodash.flatten", () => {
  test("flattens one level of nesting", () => {
    expect(lodash.flatten([1, [2, [3, [4]]]])).toEqual([1, 2, [3, [4]]]);
  });

  test("handles already-flat arrays", () => {
    expect(lodash.flatten([1, 2, 3])).toEqual([1, 2, 3]);
  });
});

describe("lodash.flattenDeep", () => {
  test("recursively flattens all levels", () => {
    expect(lodash.flattenDeep([1, [2, [3, [4]]]])).toEqual([1, 2, 3, 4]);
  });
});

describe("lodash.difference", () => {
  test("returns values in first array not in subsequent arrays", () => {
    expect(lodash.difference([1, 2, 3, 4], [2, 4])).toEqual([1, 3]);
  });

  test("returns original array if no overlap", () => {
    expect(lodash.difference([1, 2, 3], [4, 5])).toEqual([1, 2, 3]);
  });
});

describe("lodash.intersection", () => {
  test("returns values present in all arrays", () => {
    expect(lodash.intersection([1, 2, 3], [2, 3, 4])).toEqual([2, 3]);
  });

  test("returns empty array if no common values", () => {
    expect(lodash.intersection([1, 2], [3, 4])).toEqual([]);
  });
});

describe("lodash.union", () => {
  test("merges arrays with unique values", () => {
    expect(lodash.union([1, 2], [2, 3], [3, 4])).toEqual([1, 2, 3, 4]);
  });
});

describe("lodash.zip", () => {
  test("groups elements from arrays at the same index", () => {
    expect(lodash.zip([1, 2], ["a", "b"])).toEqual([[1, "a"], [2, "b"]]);
  });
});

describe("lodash.first / lodash.head", () => {
  test("returns first element", () => {
    expect(lodash.first([1, 2, 3])).toBe(1);
    expect(lodash.head([1, 2, 3])).toBe(1);
  });

  test("returns undefined for empty array", () => {
    expect(lodash.first([])).toBeUndefined();
  });
});

describe("lodash.last", () => {
  test("returns last element", () => {
    expect(lodash.last([1, 2, 3])).toBe(3);
  });

  test("returns undefined for empty array", () => {
    expect(lodash.last([])).toBeUndefined();
  });
});

describe("lodash.take", () => {
  test("takes first n elements", () => {
    expect(lodash.take([1, 2, 3, 4], 2)).toEqual([1, 2]);
  });

  test("takes 1 by default", () => {
    expect(lodash.take([1, 2, 3])).toEqual([1]);
  });
});

describe("lodash.drop", () => {
  test("drops first n elements", () => {
    expect(lodash.drop([1, 2, 3, 4], 2)).toEqual([3, 4]);
  });
});

// ---------------------------------------------------------------------------
// Collection utilities
// ---------------------------------------------------------------------------

describe("lodash.map", () => {
  test("maps over an array with an iteratee function", () => {
    expect(lodash.map([1, 2, 3], (x) => x * 2)).toEqual([2, 4, 6]);
  });

  test("maps over an object, returning an array of results", () => {
    const result = lodash.map({ a: 1, b: 2 }, (v) => v * 10);
    expect(result.sort()).toEqual([10, 20]);
  });

  test("supports shorthand property name iteratee", () => {
    const users = [{ name: "Alice" }, { name: "Bob" }];
    expect(lodash.map(users, "name")).toEqual(["Alice", "Bob"]);
  });
});

describe("lodash.filter", () => {
  test("filters an array by predicate", () => {
    expect(lodash.filter([1, 2, 3, 4], (x) => x % 2 === 0)).toEqual([2, 4]);
  });

  test("supports shorthand object match", () => {
    const users = [
      { active: true, name: "Alice" },
      { active: false, name: "Bob" },
    ];
    expect(lodash.filter(users, { active: true })).toEqual([{ active: true, name: "Alice" }]);
  });
});

describe("lodash.reduce", () => {
  test("reduces an array to a single value", () => {
    expect(lodash.reduce([1, 2, 3, 4], (acc, x) => acc + x, 0)).toBe(10);
  });

  test("uses first element as accumulator if no initial value", () => {
    expect(lodash.reduce([1, 2, 3], (acc, x) => acc + x)).toBe(6);
  });
});

describe("lodash.find", () => {
  test("returns first matching element", () => {
    expect(lodash.find([1, 2, 3, 4], (x) => x > 2)).toBe(3);
  });

  test("returns undefined if nothing matches", () => {
    expect(lodash.find([1, 2, 3], (x) => x > 10)).toBeUndefined();
  });
});

describe("lodash.every", () => {
  test("returns true if all elements satisfy predicate", () => {
    expect(lodash.every([2, 4, 6], (x) => x % 2 === 0)).toBe(true);
  });

  test("returns false if any element fails predicate", () => {
    expect(lodash.every([2, 3, 6], (x) => x % 2 === 0)).toBe(false);
  });
});

describe("lodash.some", () => {
  test("returns true if any element satisfies predicate", () => {
    expect(lodash.some([1, 2, 3], (x) => x > 2)).toBe(true);
  });

  test("returns false if no element satisfies predicate", () => {
    expect(lodash.some([1, 2, 3], (x) => x > 10)).toBe(false);
  });
});

describe("lodash.groupBy", () => {
  test("groups elements by iteratee result", () => {
    const result = lodash.groupBy([1, 2, 3, 4, 5], (x) => (x % 2 === 0 ? "even" : "odd"));
    expect(result.even).toEqual([2, 4]);
    expect(result.odd).toEqual([1, 3, 5]);
  });

  test("supports string shorthand for property grouping", () => {
    const items = [
      { type: "fruit", name: "apple" },
      { type: "veggie", name: "carrot" },
      { type: "fruit", name: "banana" },
    ];
    const grouped = lodash.groupBy(items, "type");
    expect(grouped.fruit).toHaveLength(2);
    expect(grouped.veggie).toHaveLength(1);
  });
});

describe("lodash.sortBy", () => {
  test("sorts by iteratee", () => {
    const users = [{ age: 30 }, { age: 20 }, { age: 25 }];
    expect(lodash.sortBy(users, "age")).toEqual([{ age: 20 }, { age: 25 }, { age: 30 }]);
  });
});

describe("lodash.countBy", () => {
  test("counts by iteratee result", () => {
    const result = lodash.countBy(["one", "two", "three"], (s) => s.length);
    expect(result[3]).toBe(2); // "one", "two"
    expect(result[5]).toBe(1); // "three"
  });
});

describe("lodash.flatMap", () => {
  test("maps then flattens one level", () => {
    expect(lodash.flatMap([1, 2, 3], (x) => [x, x * 2])).toEqual([1, 2, 2, 4, 3, 6]);
  });
});

// ---------------------------------------------------------------------------
// Object utilities
// ---------------------------------------------------------------------------

describe("lodash.keys", () => {
  test("returns own enumerable keys", () => {
    expect(lodash.keys({ a: 1, b: 2 })).toEqual(["a", "b"]);
  });
});

describe("lodash.values", () => {
  test("returns own enumerable values", () => {
    expect(lodash.values({ a: 1, b: 2 })).toEqual([1, 2]);
  });
});

describe("lodash.entries / lodash.toPairs", () => {
  test("returns key-value pairs", () => {
    const result = lodash.entries({ a: 1, b: 2 });
    expect(result).toEqual(expect.arrayContaining([["a", 1], ["b", 2]]));
  });
});

describe("lodash.pick", () => {
  test("picks specified keys from an object", () => {
    expect(lodash.pick({ a: 1, b: 2, c: 3 }, ["a", "c"])).toEqual({ a: 1, c: 3 });
  });
});

describe("lodash.omit", () => {
  test("omits specified keys from an object", () => {
    expect(lodash.omit({ a: 1, b: 2, c: 3 }, ["b"])).toEqual({ a: 1, c: 3 });
  });
});

describe("lodash.merge", () => {
  test("deep-merges source into destination", () => {
    const dest = { a: { x: 1 }, b: 2 };
    const src = { a: { y: 2 }, c: 3 };
    lodash.merge(dest, src);
    expect(dest).toEqual({ a: { x: 1, y: 2 }, b: 2, c: 3 });
  });
});

describe("lodash.cloneDeep", () => {
  test("produces a deep copy that does not share references", () => {
    const original = { a: { b: { c: 42 } } };
    const cloned = lodash.cloneDeep(original);
    cloned.a.b.c = 99;
    expect(original.a.b.c).toBe(42);
  });

  test("deep clones arrays", () => {
    const original = [[1, 2], [3, 4]];
    const cloned = lodash.cloneDeep(original);
    cloned[0][0] = 99;
    expect(original[0][0]).toBe(1);
  });
});

describe("lodash.get", () => {
  test("retrieves a nested value by path string", () => {
    const obj = { a: { b: { c: 42 } } };
    expect(lodash.get(obj, "a.b.c")).toBe(42);
  });

  test("returns default value when path is missing", () => {
    expect(lodash.get({}, "x.y.z", "default")).toBe("default");
  });

  test("supports bracket notation in path", () => {
    const obj = { a: [1, 2, 3] };
    expect(lodash.get(obj, "a[1]")).toBe(2);
  });
});

describe("lodash.set", () => {
  test("sets a nested property by path", () => {
    const obj = {};
    lodash.set(obj, "a.b.c", 42);
    expect(obj.a.b.c).toBe(42);
  });
});

describe("lodash.has", () => {
  test("returns true if path exists", () => {
    expect(lodash.has({ a: { b: 1 } }, "a.b")).toBe(true);
  });

  test("returns false if path does not exist", () => {
    expect(lodash.has({}, "x.y")).toBe(false);
  });
});

describe("lodash.mapValues", () => {
  test("maps the values of an object", () => {
    expect(lodash.mapValues({ a: 1, b: 2 }, (v) => v * 10)).toEqual({ a: 10, b: 20 });
  });
});

describe("lodash.defaults", () => {
  test("assigns default values for missing properties", () => {
    expect(lodash.defaults({ a: 1 }, { a: 5, b: 2 })).toEqual({ a: 1, b: 2 });
  });
});

// ---------------------------------------------------------------------------
// String utilities
// ---------------------------------------------------------------------------

describe("lodash.camelCase", () => {
  test("converts string to camelCase", () => {
    expect(lodash.camelCase("foo bar")).toBe("fooBar");
    expect(lodash.camelCase("foo-bar")).toBe("fooBar");
    expect(lodash.camelCase("Foo Bar")).toBe("fooBar");
  });
});

describe("lodash.kebabCase", () => {
  test("converts string to kebab-case", () => {
    expect(lodash.kebabCase("fooBar")).toBe("foo-bar");
    expect(lodash.kebabCase("Foo Bar")).toBe("foo-bar");
  });
});

describe("lodash.snakeCase", () => {
  test("converts string to snake_case", () => {
    expect(lodash.snakeCase("fooBar")).toBe("foo_bar");
    expect(lodash.snakeCase("Foo Bar")).toBe("foo_bar");
  });
});

describe("lodash.startCase", () => {
  test("converts to Start Case", () => {
    expect(lodash.startCase("fooBar")).toBe("Foo Bar");
  });
});

describe("lodash.capitalize", () => {
  test("capitalizes first letter, lowercases rest", () => {
    expect(lodash.capitalize("hello WORLD")).toBe("Hello world");
  });
});

describe("lodash.trim", () => {
  test("trims whitespace from both sides", () => {
    expect(lodash.trim("  hello  ")).toBe("hello");
  });

  test("trims specified characters", () => {
    expect(lodash.trim("--hello--", "-")).toBe("hello");
  });
});

describe("lodash.padStart / lodash.padEnd", () => {
  test("pads start of string", () => {
    expect(lodash.padStart("5", 4, "0")).toBe("0005");
  });

  test("pads end of string", () => {
    expect(lodash.padEnd("hi", 5, "!")).toBe("hi!!!");
  });
});

describe("lodash.startsWith / lodash.endsWith", () => {
  test("startsWith works", () => {
    expect(lodash.startsWith("foobar", "foo")).toBe(true);
    expect(lodash.startsWith("foobar", "bar")).toBe(false);
  });

  test("endsWith works", () => {
    expect(lodash.endsWith("foobar", "bar")).toBe(true);
    expect(lodash.endsWith("foobar", "foo")).toBe(false);
  });
});

describe("lodash.repeat", () => {
  test("repeats string n times", () => {
    expect(lodash.repeat("ab", 3)).toBe("ababab");
  });
});

describe("lodash.truncate", () => {
  test("truncates string to given length with ellipsis", () => {
    const result = lodash.truncate("hello world", { length: 8 });
    expect(result.length).toBeLessThanOrEqual(8);
    expect(result.endsWith("...")).toBe(true);
  });
});

// ---------------------------------------------------------------------------
// Number utilities
// ---------------------------------------------------------------------------

describe("lodash.clamp", () => {
  test("clamps value between lower and upper bounds", () => {
    expect(lodash.clamp(10, 1, 5)).toBe(5);
    expect(lodash.clamp(-10, 1, 5)).toBe(1);
    expect(lodash.clamp(3, 1, 5)).toBe(3);
  });
});

describe("lodash.inRange", () => {
  test("returns true if value is in range", () => {
    expect(lodash.inRange(3, 1, 5)).toBe(true);
    expect(lodash.inRange(0, 1, 5)).toBe(false);
  });

  test("supports two-argument form (0 to end)", () => {
    expect(lodash.inRange(3, 5)).toBe(true);
    expect(lodash.inRange(5, 5)).toBe(false);
  });
});

describe("lodash.random", () => {
  test("returns a number within the given bounds", () => {
    for (let i = 0; i < 20; i++) {
      const r = lodash.random(1, 10);
      expect(r).toBeGreaterThanOrEqual(1);
      expect(r).toBeLessThanOrEqual(10);
    }
  });
});

// ---------------------------------------------------------------------------
// Function utilities
// ---------------------------------------------------------------------------

describe("lodash.once", () => {
  test("only calls the function once regardless of invocation count", () => {
    let count = 0;
    const inc = lodash.once(() => ++count);
    inc();
    inc();
    inc();
    expect(count).toBe(1);
  });

  test("returns the result of the first call on subsequent calls", () => {
    const f = lodash.once(() => 42);
    expect(f()).toBe(42);
    expect(f()).toBe(42);
  });
});

describe("lodash.memoize", () => {
  test("caches results of expensive computation", () => {
    let callCount = 0;
    const expensive = lodash.memoize((n) => {
      callCount++;
      return n * 2;
    });
    expect(expensive(5)).toBe(10);
    expect(expensive(5)).toBe(10);
    expect(callCount).toBe(1);
  });

  test("does not conflate different arguments", () => {
    const f = lodash.memoize((n) => n * 3);
    expect(f(2)).toBe(6);
    expect(f(4)).toBe(12);
  });
});

describe("lodash.debounce (basic structure)", () => {
  test("returns a function", () => {
    const debounced = lodash.debounce(() => {}, 100);
    expect(typeof debounced).toBe("function");
  });

  test("debounced function has a cancel method", () => {
    const debounced = lodash.debounce(() => {}, 100);
    expect(typeof debounced.cancel).toBe("function");
  });
});

describe("lodash.throttle (basic structure)", () => {
  test("returns a function", () => {
    const throttled = lodash.throttle(() => {}, 100);
    expect(typeof throttled).toBe("function");
  });
});

describe("lodash.partial", () => {
  test("partially applies arguments", () => {
    const add = (a, b) => a + b;
    const add5 = lodash.partial(add, 5);
    expect(add5(3)).toBe(8);
    expect(add5(10)).toBe(15);
  });
});

describe("lodash.curry", () => {
  test("curries a function", () => {
    const add = (a, b, c) => a + b + c;
    const curried = lodash.curry(add);
    expect(curried(1)(2)(3)).toBe(6);
    expect(curried(1, 2)(3)).toBe(6);
  });
});

// ---------------------------------------------------------------------------
// Type checks
// ---------------------------------------------------------------------------

describe("Type checks", () => {
  test("lodash.isArray", () => {
    expect(lodash.isArray([])).toBe(true);
    expect(lodash.isArray({})).toBe(false);
  });

  test("lodash.isObject", () => {
    expect(lodash.isObject({})).toBe(true);
    expect(lodash.isObject([])).toBe(true);
    expect(lodash.isObject(null)).toBe(false);
  });

  test("lodash.isString", () => {
    expect(lodash.isString("hi")).toBe(true);
    expect(lodash.isString(1)).toBe(false);
  });

  test("lodash.isNumber", () => {
    expect(lodash.isNumber(42)).toBe(true);
    expect(lodash.isNumber("42")).toBe(false);
    expect(lodash.isNumber(NaN)).toBe(true); // NaN is typeof number
  });

  test("lodash.isFunction", () => {
    expect(lodash.isFunction(() => {})).toBe(true);
    expect(lodash.isFunction({})).toBe(false);
  });

  test("lodash.isNull", () => {
    expect(lodash.isNull(null)).toBe(true);
    expect(lodash.isNull(undefined)).toBe(false);
  });

  test("lodash.isUndefined", () => {
    expect(lodash.isUndefined(undefined)).toBe(true);
    expect(lodash.isUndefined(null)).toBe(false);
  });

  test("lodash.isEmpty", () => {
    expect(lodash.isEmpty([])).toBe(true);
    expect(lodash.isEmpty({})).toBe(true);
    expect(lodash.isEmpty("")).toBe(true);
    expect(lodash.isEmpty([1])).toBe(false);
  });

  test("lodash.isEqual", () => {
    expect(lodash.isEqual({ a: 1, b: [2, 3] }, { a: 1, b: [2, 3] })).toBe(true);
    expect(lodash.isEqual({ a: 1 }, { a: 2 })).toBe(false);
  });

  test("lodash.isNil", () => {
    expect(lodash.isNil(null)).toBe(true);
    expect(lodash.isNil(undefined)).toBe(true);
    expect(lodash.isNil(0)).toBe(false);
  });

  test("lodash.isPlainObject", () => {
    expect(lodash.isPlainObject({})).toBe(true);
    expect(lodash.isPlainObject(new Date())).toBe(false);
    expect(lodash.isPlainObject([])).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// Utility functions
// ---------------------------------------------------------------------------

describe("lodash.identity", () => {
  test("returns its first argument", () => {
    expect(lodash.identity(42)).toBe(42);
    expect(lodash.identity("hello")).toBe("hello");
  });
});

describe("lodash.noop", () => {
  test("returns undefined", () => {
    expect(lodash.noop()).toBeUndefined();
  });
});

describe("lodash.uniqueId", () => {
  test("returns a unique string on each call", () => {
    const a = lodash.uniqueId();
    const b = lodash.uniqueId();
    expect(a).not.toBe(b);
  });

  test("accepts an optional prefix", () => {
    const id = lodash.uniqueId("user_");
    expect(id.startsWith("user_")).toBe(true);
  });
});

describe("lodash.times", () => {
  test("calls iteratee n times and collects results", () => {
    expect(lodash.times(3, (i) => i * 2)).toEqual([0, 2, 4]);
  });
});

// ===========================================================================
// PART 2 / DEMO APPLICATION SURFACE
//
// These tests represent only the lodash functionality exercised by the DEMO
// application. A use-case-driven projection must pass these and only needs
// to pass these.
//
// For the take-home: identify which of these map to actual DEMO usage, and
// verify your projection satisfies exactly this subset.
// ===========================================================================

describe("[DEMO SURFACE] Core array operations used by DEMO", () => {
  test("lodash.map with iteratee function", () => {
    expect(lodash.map([1, 2, 3], (x) => x + 1)).toEqual([2, 3, 4]);
  });

  test("lodash.filter with predicate function", () => {
    expect(lodash.filter([1, 2, 3, 4, 5], (x) => x > 3)).toEqual([4, 5]);
  });

  test("lodash.reduce with accumulator", () => {
    expect(lodash.reduce([1, 2, 3], (sum, x) => sum + x, 0)).toBe(6);
  });

  test("lodash.uniq removes duplicates", () => {
    expect(lodash.uniq([1, 1, 2, 3, 3])).toEqual([1, 2, 3]);
  });

  test("lodash.flatten flattens one level", () => {
    expect(lodash.flatten([[1, 2], [3, 4]])).toEqual([1, 2, 3, 4]);
  });
});

describe("[DEMO SURFACE] Core object operations used by DEMO", () => {
  test("lodash.get retrieves nested value", () => {
    expect(lodash.get({ user: { name: "Alice" } }, "user.name")).toBe("Alice");
  });

  test("lodash.get returns default for missing path", () => {
    expect(lodash.get({}, "x.y", null)).toBeNull();
  });

  test("lodash.pick selects keys", () => {
    expect(lodash.pick({ id: 1, name: "Alice", secret: "x" }, ["id", "name"])).toEqual({
      id: 1,
      name: "Alice",
    });
  });

  test("lodash.cloneDeep produces independent copy", () => {
    const src = { a: [1, 2, 3] };
    const copy = lodash.cloneDeep(src);
    copy.a.push(4);
    expect(src.a).toHaveLength(3);
  });
});

describe("[DEMO SURFACE] Type checks used by DEMO", () => {
  test("lodash.isArray correctly identifies arrays", () => {
    expect(lodash.isArray([])).toBe(true);
    expect(lodash.isArray("string")).toBe(false);
  });

  test("lodash.isString correctly identifies strings", () => {
    expect(lodash.isString("hello")).toBe(true);
    expect(lodash.isString(42)).toBe(false);
  });

  test("lodash.isEmpty identifies empty collections", () => {
    expect(lodash.isEmpty([])).toBe(true);
    expect(lodash.isEmpty({})).toBe(true);
    expect(lodash.isEmpty([1])).toBe(false);
  });
});

describe("[DEMO SURFACE] String utilities used by DEMO", () => {
  test("lodash.camelCase converts to camelCase", () => {
    expect(lodash.camelCase("hello world")).toBe("helloWorld");
  });

  test("lodash.capitalize capitalizes first letter", () => {
    expect(lodash.capitalize("hello")).toBe("Hello");
  });

  test("lodash.trim removes surrounding whitespace", () => {
    expect(lodash.trim("  hello  ")).toBe("hello");
  });
});

describe("[DEMO SURFACE] Function utilities used by DEMO", () => {
  test("lodash.once returns same value on multiple calls", () => {
    let n = 0;
    const f = lodash.once(() => ++n);
    f(); f(); f();
    expect(n).toBe(1);
  });
});

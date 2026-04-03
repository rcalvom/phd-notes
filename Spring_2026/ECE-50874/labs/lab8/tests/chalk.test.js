/**
 * chalk.test.js
 * ─────────────────────────────────────────────────────────────
 * HARP Lab – Chalk Test Suite
 *
 * Covers:
 *   1.  Basic foreground colors (16-color names)
 *   2.  Basic background colors
 *   3.  Text modifiers (bold, italic, underline, dim, …)
 *   4.  Chaining / builder pattern (stateful API)
 *   5.  Chalk instance creation and `level` mutation (stateful API)
 *   6.  RGB / Hex / BGHex / ANSI-256 dynamic color methods
 *   7.  Template-literal tag support
 *   8.  Multi-argument (variadic) call support
 *   9.  Nested / composed styling
 *  10.  Level-0 disables all output; `visible` modifier behavior
 *  11.  ANSI escape sequence format validation (regression guard)
 * ─────────────────────────────────────────────────────────────
 */

import { Chalk } from 'chalk';

// ── Helpers ────────────────────────────────────────────────────────────────

/** Strip every ANSI escape sequence from a string. */
const strip = (s) => s.replace(/\u001b\[[0-9;]*m/g, '');

/** Return true when the string contains at least one ANSI CSI sequence. */
const hasAnsi = (s) => /\u001b\[/.test(s);

/** Extract the raw open/close escape codes surrounding the payload. */
const escapes = (s) => s.match(/\u001b\[[0-9;]*m/g) ?? [];

// ── Fixture instances ──────────────────────────────────────────────────────

let c;   // level-3, full truecolor — recreated per test group

// ══════════════════════════════════════════════════════════════════════════
// 1. Basic foreground colors
// ══════════════════════════════════════════════════════════════════════════
describe('Basic foreground colors', () => {
  beforeEach(() => { c = new Chalk({ level: 3 }); });

  const COLOR_TESTS = [
    ['black',   '\u001b[30m', '\u001b[39m'],
    ['red',     '\u001b[31m', '\u001b[39m'],
    ['green',   '\u001b[32m', '\u001b[39m'],
    ['yellow',  '\u001b[33m', '\u001b[39m'],
    ['blue',    '\u001b[34m', '\u001b[39m'],
    ['magenta', '\u001b[35m', '\u001b[39m'],
    ['cyan',    '\u001b[36m', '\u001b[39m'],
    ['white',   '\u001b[37m', '\u001b[39m'],
    ['gray',    '\u001b[90m', '\u001b[39m'],
    ['grey',    '\u001b[90m', '\u001b[39m'],  // alias
  ];

  test.each(COLOR_TESTS)(
    'chalk.%s wraps text with correct ANSI codes',
    (color, open, close) => {
      const result = c[color]('text');
      expect(result).toBe(`${open}text${close}`);
    }
  );

  test('each color preserves the original text', () => {
    COLOR_TESTS.forEach(([color]) => {
      expect(strip(c[color]('hello'))).toBe('hello');
    });
  });
});

// ══════════════════════════════════════════════════════════════════════════
// 2. Basic background colors
// ══════════════════════════════════════════════════════════════════════════
describe('Basic background colors', () => {
  beforeEach(() => { c = new Chalk({ level: 3 }); });

  const BG_TESTS = [
    ['bgBlack',   '\u001b[40m',  '\u001b[49m'],
    ['bgRed',     '\u001b[41m',  '\u001b[49m'],
    ['bgGreen',   '\u001b[42m',  '\u001b[49m'],
    ['bgYellow',  '\u001b[43m',  '\u001b[49m'],
    ['bgBlue',    '\u001b[44m',  '\u001b[49m'],
    ['bgMagenta', '\u001b[45m',  '\u001b[49m'],
    ['bgCyan',    '\u001b[46m',  '\u001b[49m'],
    ['bgWhite',   '\u001b[47m',  '\u001b[49m'],
  ];

  test.each(BG_TESTS)(
    'chalk.%s wraps text with correct ANSI codes',
    (color, open, close) => {
      const result = c[color]('text');
      expect(result).toBe(`${open}text${close}`);
    }
  );

  test('background colors preserve text content', () => {
    expect(strip(c.bgCyan('hello'))).toBe('hello');
  });
});

// ══════════════════════════════════════════════════════════════════════════
// 3. Text modifiers
// ══════════════════════════════════════════════════════════════════════════
describe('Text modifiers', () => {
  beforeEach(() => { c = new Chalk({ level: 3 }); });

  const MODIFIER_TESTS = [
    ['reset',         '\u001b[0m',  '\u001b[0m'],
    ['bold',          '\u001b[1m',  '\u001b[22m'],
    ['dim',           '\u001b[2m',  '\u001b[22m'],
    ['italic',        '\u001b[3m',  '\u001b[23m'],
    ['underline',     '\u001b[4m',  '\u001b[24m'],
    ['inverse',       '\u001b[7m',  '\u001b[27m'],
    ['hidden',        '\u001b[8m',  '\u001b[28m'],
    ['strikethrough', '\u001b[9m',  '\u001b[29m'],
    ['overline',      '\u001b[53m', '\u001b[55m'],
  ];

  test.each(MODIFIER_TESTS)(
    'chalk.%s wraps text with correct ANSI codes',
    (modifier, open, close) => {
      const result = c[modifier]('text');
      expect(result).toBe(`${open}text${close}`);
    }
  );

  test('modifier output still contains original text', () => {
    MODIFIER_TESTS.forEach(([modifier]) => {
      expect(strip(c[modifier]('hello'))).toBe('hello');
    });
  });
});

// ══════════════════════════════════════════════════════════════════════════
// 4. Chaining / builder pattern  ← STATEFUL API
// ══════════════════════════════════════════════════════════════════════════
describe('Chaining (stateful builder)', () => {
  beforeEach(() => { c = new Chalk({ level: 3 }); });

  test('red.bold produces both modifiers', () => {
    const result = c.red.bold('text');
    expect(result).toBe('\u001b[31m\u001b[1mtext\u001b[22m\u001b[39m');
  });

  test('underline.italic produces both modifiers', () => {
    const result = c.underline.italic('text');
    expect(result).toBe('\u001b[4m\u001b[3mtext\u001b[23m\u001b[24m');
  });

  test('bgRed.white foreground + background together', () => {
    const result = c.bgRed.white('text');
    expect(result).toBe('\u001b[41m\u001b[37mtext\u001b[39m\u001b[49m');
  });

  test('chains do not mutate each other (independence)', () => {
    const redBold  = c.red.bold;
    const redItal  = c.red.italic;
    const redOnly  = c.red;

    expect(redBold('x')).toContain('\u001b[1m');   // bold code
    expect(redItal('x')).toContain('\u001b[3m');   // italic code
    expect(redOnly('x')).not.toContain('\u001b[1m');
    expect(redOnly('x')).not.toContain('\u001b[3m');
  });

  test('long chain: red.bold.underline.italic', () => {
    const result = c.red.bold.underline.italic('text');
    expect(strip(result)).toBe('text');
    expect(result).toContain('\u001b[31m');
    expect(result).toContain('\u001b[1m');
    expect(result).toContain('\u001b[4m');
    expect(result).toContain('\u001b[3m');
  });

  test('a saved chain reference is reusable', () => {
    const errorStyle = c.red.bold;
    expect(errorStyle('first')).toBe(errorStyle('first'));
    expect(strip(errorStyle('msg'))).toBe('msg');
  });
});

// ══════════════════════════════════════════════════════════════════════════
// 5. Chalk instance & `level` mutation  ← STATEFUL API
// ══════════════════════════════════════════════════════════════════════════
describe('Chalk instance and level mutation (stateful)', () => {
  test('new Chalk({ level }) respects initial level', () => {
    const inst = new Chalk({ level: 3 });
    expect(inst.level).toBe(3);
  });

  test('level can be mutated on the instance', () => {
    const inst = new Chalk({ level: 3 });
    inst.level = 1;
    expect(inst.level).toBe(1);
  });

  test('level 0 disables all ANSI output', () => {
    const inst = new Chalk({ level: 3 });
    expect(hasAnsi(inst.red('text'))).toBe(true);

    inst.level = 0;                            // mutate → disable
    expect(inst.red('text')).toBe('text');
    expect(hasAnsi(inst.bold('text'))).toBe(false);
  });

  test('restoring level re-enables ANSI output', () => {
    const inst = new Chalk({ level: 3 });
    inst.level = 0;
    inst.level = 3;                            // restore
    expect(hasAnsi(inst.red('text'))).toBe(true);
  });

  test('two instances are independent', () => {
    const a = new Chalk({ level: 3 });
    const b = new Chalk({ level: 3 });
    a.level = 0;
    expect(hasAnsi(b.red('text'))).toBe(true); // b unaffected
    expect(hasAnsi(a.red('text'))).toBe(false);
  });

  test('level 1 (basic 16 colors) still produces ANSI', () => {
    const inst = new Chalk({ level: 1 });
    expect(hasAnsi(inst.red('text'))).toBe(true);
    expect(inst.red('text')).toBe('\u001b[31mtext\u001b[39m');
  });

  test('level 2 (256-color) still produces ANSI', () => {
    const inst = new Chalk({ level: 2 });
    expect(hasAnsi(inst.green('text'))).toBe(true);
  });

  test('chain built before level change reflects new level', () => {
    const inst  = new Chalk({ level: 3 });
    const style = inst.red.bold;              // build chain at level 3
    inst.level  = 0;                          // then disable
    expect(style('text')).toBe('text');       // chain now produces plain text
  });
});

// ══════════════════════════════════════════════════════════════════════════
// 6. Dynamic color methods: RGB / Hex / BGHex / ANSI-256
// ══════════════════════════════════════════════════════════════════════════
describe('Dynamic color methods', () => {
  beforeEach(() => { c = new Chalk({ level: 3 }); });

  test('rgb() produces truecolor 38;2;R;G;B sequence', () => {
    expect(c.rgb(255, 99, 71)('tomato')).toBe(
      '\u001b[38;2;255;99;71mtomato\u001b[39m'
    );
  });

  test('hex() produces correct truecolor output for #FF6347', () => {
    const result = c.hex('#FF6347')('tomato');
    expect(strip(result)).toBe('tomato');
    expect(result).toContain('\u001b[38;2;');
  });

  test('hex() #FF0000 maps to rgb(255,0,0)', () => {
    expect(c.hex('#FF0000')('red')).toBe(
      '\u001b[38;2;255;0;0mred\u001b[39m'
    );
  });

  test('bgRgb() produces background truecolor sequence', () => {
    expect(c.bgRgb(0, 128, 0)('green bg')).toBe(
      '\u001b[48;2;0;128;0mgreen bg\u001b[49m'
    );
  });

  test('bgHex() produces background truecolor sequence', () => {
    const result = c.bgHex('#FF0000')('bg hex');
    expect(result).toBe('\u001b[48;2;255;0;0mbg hex\u001b[49m');
  });

  test('ansi256() produces 38;5;N sequence', () => {
    expect(c.ansi256(196)('ansi256')).toBe(
      '\u001b[38;5;196mansi256\u001b[39m'
    );
  });

  test('bgAnsi256() produces 48;5;N sequence', () => {
    expect(c.bgAnsi256(196)('bg ansi256')).toBe(
      '\u001b[48;5;196mbg ansi256\u001b[49m'
    );
  });

  test('rgb() chained with bold', () => {
    const result = c.rgb(255, 0, 0).bold('bold red');
    expect(result).toContain('\u001b[38;2;255;0;0m');
    expect(result).toContain('\u001b[1m');
    expect(strip(result)).toBe('bold red');
  });

  test('hex() downgrades gracefully at level 1', () => {
    const c1 = new Chalk({ level: 1 });
    // At level 1, truecolor falls back to nearest 16-color ANSI
    const result = c1.hex('#FF0000')('text');
    expect(hasAnsi(result)).toBe(true);
    expect(strip(result)).toBe('text');
  });
});

// ══════════════════════════════════════════════════════════════════════════
// 7. Template-literal tag support
// ══════════════════════════════════════════════════════════════════════════
describe('Template-literal tag', () => {
  beforeEach(() => { c = new Chalk({ level: 3 }); });

  test('tagged template produces same output as function call for static string', () => {
    // eslint-disable-next-line no-useless-concat
    const tagged = c.red`hello`;
    const called = c.red('hello');
    expect(tagged).toBe(called);
  });

  test('tagged template with interpolation includes all parts', () => {
    const name   = 'World';
    const result = c.green`Hello ${name}!`;
    // chalk tag joins strings/values; exact format may vary, but text must be present
    expect(strip(result)).toContain('Hello');
    expect(strip(result)).toContain('World');
    expect(hasAnsi(result)).toBe(true);
  });

  test('tagged template respects level 0', () => {
    c.level = 0;
    expect(c.red`hello`).toBe('hello');
  });
});

// ══════════════════════════════════════════════════════════════════════════
// 8. Variadic (multi-argument) calls
// ══════════════════════════════════════════════════════════════════════════
describe('Variadic calls', () => {
  beforeEach(() => { c = new Chalk({ level: 3 }); });

  test('multiple string arguments are joined with spaces', () => {
    const result = c.red('a', 'b', 'c');
    expect(strip(result)).toBe('a b c');
  });

  test('multi-arg result is still wrapped in ANSI', () => {
    const result = c.blue('hello', 'world');
    expect(result).toBe('\u001b[34mhello world\u001b[39m');
  });

  test('single-arg and multi-arg produce same wrapper codes', () => {
    const single = c.green('hello world');
    const multi  = c.green('hello', 'world');
    expect(single).toBe(multi);
  });
});

// ══════════════════════════════════════════════════════════════════════════
// 9. Nested / composed styling
// ══════════════════════════════════════════════════════════════════════════
describe('Nested and composed styling', () => {
  beforeEach(() => { c = new Chalk({ level: 3 }); });

  test('nested color resets correctly at inner close', () => {
    const result = c.red('Hello ' + c.blue('World') + '!');
    // After the inner blue closes (→ [39m), red resumes
    expect(strip(result)).toBe('Hello World!');
    expect(result).toContain('\u001b[31m');  // outer red open
    expect(result).toContain('\u001b[34m');  // inner blue open
  });

  test('nested bold inside colored text', () => {
    const result = c.green('start ' + c.bold('bold part') + ' end');
    expect(strip(result)).toBe('start bold part end');
    expect(result).toContain('\u001b[32m');
    expect(result).toContain('\u001b[1m');
  });

  test('composed styles from saved chains', () => {
    const warning = c.yellow.bold;
    const error   = c.red.underline;
    expect(strip(warning('warn'))).toBe('warn');
    expect(strip(error('err'))).toBe('err');
    expect(warning('warn')).toContain('\u001b[33m');
    expect(error('err')).toContain('\u001b[31m');
  });
});

// ══════════════════════════════════════════════════════════════════════════
// 10. Level-0 and `visible` modifier
// ══════════════════════════════════════════════════════════════════════════
describe('Level 0 and visible modifier', () => {
  test('level 0: all style methods return plain text', () => {
    const c0 = new Chalk({ level: 0 });
    expect(c0.red('text')).toBe('text');
    expect(c0.bold('text')).toBe('text');
    expect(c0.bgBlue('text')).toBe('text');
    expect(c0.rgb(1, 2, 3)('text')).toBe('text');
    expect(c0.hex('#abc')('text')).toBe('text');
  });

  test('visible: renders normally at level > 0', () => {
    const c3 = new Chalk({ level: 3 });
    expect(c3.visible('text')).toBe('text');
  });

  test('visible: hidden at level 0', () => {
    const c0 = new Chalk({ level: 0 });
    expect(c0.visible('text')).toBe('');
  });

  test('visible: hidden when level mutated to 0', () => {
    const inst = new Chalk({ level: 3 });
    expect(inst.visible('text')).toBe('text');
    inst.level = 0;
    expect(inst.visible('text')).toBe('');
  });
});

// ══════════════════════════════════════════════════════════════════════════
// 11. ANSI escape sequence format validation
// ══════════════════════════════════════════════════════════════════════════
describe('ANSI escape sequence format', () => {
  beforeEach(() => { c = new Chalk({ level: 3 }); });

  test('every styled string starts with ESC[', () => {
    expect(c.red('x')).toMatch(/^\u001b\[/);
  });

  test('every styled string ends with a reset/close code', () => {
    expect(c.red('x')).toMatch(/\u001b\[\d+m$/);
  });

  test('escape codes are well-formed CSI sequences', () => {
    const codes = escapes(c.red.bold('text'));
    codes.forEach((code) => {
      expect(code).toMatch(/^\u001b\[\d+(;\d+)*m$/);
    });
  });

  test('plain text has no escape sequences', () => {
    const result = new Chalk({ level: 0 }).red('hello');
    expect(escapes(result)).toHaveLength(0);
  });

  test('truecolor rgb has the 38;2;R;G;B format', () => {
    const result = c.rgb(10, 20, 30)('x');
    expect(result).toMatch(/\u001b\[38;2;10;20;30m/);
  });

  test('truecolor bgRgb has the 48;2;R;G;B format', () => {
    const result = c.bgRgb(10, 20, 30)('x');
    expect(result).toMatch(/\u001b\[48;2;10;20;30m/);
  });

  test('ansi256 has the 38;5;N format', () => {
    const result = c.ansi256(200)('x');
    expect(result).toMatch(/\u001b\[38;5;200m/);
  });

  test('bgAnsi256 has the 48;5;N format', () => {
    const result = c.bgAnsi256(200)('x');
    expect(result).toMatch(/\u001b\[48;5;200m/);
  });
});

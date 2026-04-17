const ESC = '\u001b[';

const STATIC_STYLE_DEFS = {
  reset: { kind: 'modifier', open: '0', close: '0' },
  bold: { kind: 'modifier', open: '1', close: '22' },
  dim: { kind: 'modifier', open: '2', close: '22' },
  italic: { kind: 'modifier', open: '3', close: '23' },
  underline: { kind: 'modifier', open: '4', close: '24' },
  inverse: { kind: 'modifier', open: '7', close: '27' },
  hidden: { kind: 'modifier', open: '8', close: '28' },
  strikethrough: { kind: 'modifier', open: '9', close: '29' },
  overline: { kind: 'modifier', open: '53', close: '55' },
  black: { kind: 'foreground', open: '30', close: '39' },
  red: { kind: 'foreground', open: '31', close: '39' },
  green: { kind: 'foreground', open: '32', close: '39' },
  yellow: { kind: 'foreground', open: '33', close: '39' },
  blue: { kind: 'foreground', open: '34', close: '39' },
  magenta: { kind: 'foreground', open: '35', close: '39' },
  cyan: { kind: 'foreground', open: '36', close: '39' },
  white: { kind: 'foreground', open: '37', close: '39' },
  gray: { kind: 'foreground', open: '90', close: '39' },
  grey: { kind: 'foreground', open: '90', close: '39' },
  blackBright: { kind: 'foreground', open: '90', close: '39' },
  redBright: { kind: 'foreground', open: '91', close: '39' },
  greenBright: { kind: 'foreground', open: '92', close: '39' },
  yellowBright: { kind: 'foreground', open: '93', close: '39' },
  blueBright: { kind: 'foreground', open: '94', close: '39' },
  magentaBright: { kind: 'foreground', open: '95', close: '39' },
  cyanBright: { kind: 'foreground', open: '96', close: '39' },
  whiteBright: { kind: 'foreground', open: '97', close: '39' },
  bgBlack: { kind: 'background', open: '40', close: '49' },
  bgRed: { kind: 'background', open: '41', close: '49' },
  bgGreen: { kind: 'background', open: '42', close: '49' },
  bgYellow: { kind: 'background', open: '43', close: '49' },
  bgBlue: { kind: 'background', open: '44', close: '49' },
  bgMagenta: { kind: 'background', open: '45', close: '49' },
  bgCyan: { kind: 'background', open: '46', close: '49' },
  bgWhite: { kind: 'background', open: '47', close: '49' },
  bgGray: { kind: 'background', open: '100', close: '49' },
  bgGrey: { kind: 'background', open: '100', close: '49' },
  bgBlackBright: { kind: 'background', open: '100', close: '49' },
  bgRedBright: { kind: 'background', open: '101', close: '49' },
  bgGreenBright: { kind: 'background', open: '102', close: '49' },
  bgYellowBright: { kind: 'background', open: '103', close: '49' },
  bgBlueBright: { kind: 'background', open: '104', close: '49' },
  bgMagentaBright: { kind: 'background', open: '105', close: '49' },
  bgCyanBright: { kind: 'background', open: '106', close: '49' },
  bgWhiteBright: { kind: 'background', open: '107', close: '49' },
};

const ANSI16_PALETTE = [
  { rgb: [0, 0, 0], fg: 30, bg: 40 },
  { rgb: [205, 49, 49], fg: 31, bg: 41 },
  { rgb: [13, 188, 121], fg: 32, bg: 42 },
  { rgb: [229, 229, 16], fg: 33, bg: 43 },
  { rgb: [36, 114, 200], fg: 34, bg: 44 },
  { rgb: [188, 63, 188], fg: 35, bg: 45 },
  { rgb: [17, 168, 205], fg: 36, bg: 46 },
  { rgb: [229, 229, 229], fg: 37, bg: 47 },
  { rgb: [102, 102, 102], fg: 90, bg: 100 },
  { rgb: [241, 76, 76], fg: 91, bg: 101 },
  { rgb: [35, 209, 139], fg: 92, bg: 102 },
  { rgb: [245, 245, 67], fg: 93, bg: 103 },
  { rgb: [59, 142, 234], fg: 94, bg: 104 },
  { rgb: [214, 112, 214], fg: 95, bg: 105 },
  { rgb: [41, 184, 219], fg: 96, bg: 106 },
  { rgb: [255, 255, 255], fg: 97, bg: 107 },
];

function ansi(code) {
  return `${ESC}${code}m`;
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function normalizeLevel(level) {
  const numeric = Number.isFinite(level) ? Math.trunc(level) : 0;
  return clamp(numeric, 0, 3);
}

function normalizeChannel(value) {
  const numeric = Number(value);
  if (!Number.isFinite(numeric)) {
    return 0;
  }

  return clamp(Math.round(numeric), 0, 255);
}

function normalizeAnsi256(index) {
  const numeric = Number(index);
  if (!Number.isFinite(numeric)) {
    return 0;
  }

  return clamp(Math.round(numeric), 0, 255);
}

function parseHexColor(color) {
  const hex = String(color).trim().replace(/^#/, '');
  const normalized = hex.length === 3
    ? hex.split('').map((digit) => digit + digit).join('')
    : hex;

  if (!/^[\da-fA-F]{6}$/.test(normalized)) {
    return [0, 0, 0];
  }

  return [
    Number.parseInt(normalized.slice(0, 2), 16),
    Number.parseInt(normalized.slice(2, 4), 16),
    Number.parseInt(normalized.slice(4, 6), 16),
  ];
}

function rgbToAnsi256(red, green, blue) {
  if (red === green && green === blue) {
    if (red < 8) {
      return 16;
    }

    if (red > 248) {
      return 231;
    }

    return 232 + Math.round(((red - 8) / 247) * 24);
  }

  const r = Math.round((red / 255) * 5);
  const g = Math.round((green / 255) * 5);
  const b = Math.round((blue / 255) * 5);
  return 16 + (36 * r) + (6 * g) + b;
}

function ansi256ToRgb(index) {
  if (index < 16) {
    return ANSI16_PALETTE[index].rgb;
  }

  if (index >= 232) {
    const shade = 8 + ((index - 232) * 10);
    return [shade, shade, shade];
  }

  const cubeIndex = index - 16;
  const blue = cubeIndex % 6;
  const green = Math.floor(cubeIndex / 6) % 6;
  const red = Math.floor(cubeIndex / 36) % 6;
  const scale = [0, 95, 135, 175, 215, 255];
  return [scale[red], scale[green], scale[blue]];
}

function nearestAnsi16Code(red, green, blue, background) {
  let best = ANSI16_PALETTE[0];
  let minDistance = Number.POSITIVE_INFINITY;

  for (const entry of ANSI16_PALETTE) {
    const [r, g, b] = entry.rgb;
    const distance = ((red - r) ** 2) + ((green - g) ** 2) + ((blue - b) ** 2);

    if (distance < minDistance) {
      minDistance = distance;
      best = entry;
    }
  }

  return background ? best.bg : best.fg;
}

function isTemplateCall(args) {
  return Array.isArray(args[0]) && Array.isArray(args[0].raw);
}

function stringifyArgs(args) {
  if (args.length === 0) {
    return '';
  }

  if (isTemplateCall(args)) {
    const [strings, ...values] = args;
    let output = '';

    for (let index = 0; index < strings.length; index += 1) {
      output += strings[index];

      if (index < values.length) {
        output += String(values[index]);
      }
    }

    return output;
  }

  return args.map((value) => String(value)).join(' ');
}

function appendLayer(layers, layer) {
  if (layer.kind === 'foreground' || layer.kind === 'background') {
    return [...layers.filter((entry) => entry.kind !== layer.kind), layer];
  }

  return [...layers, layer];
}

function wrapWithCodes(text, open, close) {
  if (text.includes(close)) {
    return `${open}${text.split(close).join(`${close}${open}`)}${close}`;
  }

  return `${open}${text}${close}`;
}

function createStaticLayer(name) {
  const definition = STATIC_STYLE_DEFS[name];

  return {
    kind: definition.kind,
    resolve() {
      return {
        open: ansi(definition.open),
        close: ansi(definition.close),
      };
    },
  };
}

function createRgbLayer(red, green, blue, background) {
  const r = normalizeChannel(red);
  const g = normalizeChannel(green);
  const b = normalizeChannel(blue);
  const prefix = background ? 48 : 38;
  const close = ansi(background ? 49 : 39);

  return {
    kind: background ? 'background' : 'foreground',
    resolve(level) {
      if (level >= 3) {
        return {
          open: ansi(`${prefix};2;${r};${g};${b}`),
          close,
        };
      }

      if (level >= 2) {
        return {
          open: ansi(`${prefix};5;${rgbToAnsi256(r, g, b)}`),
          close,
        };
      }

      return {
        open: ansi(nearestAnsi16Code(r, g, b, background)),
        close,
      };
    },
  };
}

function createAnsi256Layer(index, background) {
  const normalizedIndex = normalizeAnsi256(index);
  const prefix = background ? 48 : 38;
  const close = ansi(background ? 49 : 39);

  return {
    kind: background ? 'background' : 'foreground',
    resolve(level) {
      if (level >= 2) {
        return {
          open: ansi(`${prefix};5;${normalizedIndex}`),
          close,
        };
      }

      const [red, green, blue] = ansi256ToRgb(normalizedIndex);
      return {
        open: ansi(nearestAnsi16Code(red, green, blue, background)),
        close,
      };
    },
  };
}

function createHexLayer(color, background) {
  const [red, green, blue] = parseHexColor(color);
  return createRgbLayer(red, green, blue, background);
}

function renderStyledText(state, layers, visible, args) {
  const text = stringifyArgs(args);

  if (visible && state.level === 0) {
    return '';
  }

  if (state.level === 0 || layers.length === 0) {
    return text;
  }

  let output = text;

  for (let index = layers.length - 1; index >= 0; index -= 1) {
    const codes = layers[index].resolve(state.level);
    output = wrapWithCodes(output, codes.open, codes.close);
  }

  return output;
}

function createBuilder(state, layers = [], visible = false) {
  const callable = function (...args) {
    return renderStyledText(state, layers, visible, args);
  };

  Object.setPrototypeOf(callable, Chalk.prototype);

  return new Proxy(callable, {
    apply(_target, _thisArg, args) {
      return renderStyledText(state, layers, visible, args);
    },

    get(target, property, receiver) {
      if (property === 'level') {
        return state.level;
      }

      if (property === 'visible') {
        return createBuilder(state, layers, true);
      }

      if (property === 'rgb') {
        return (red, green, blue) => createBuilder(
          state,
          appendLayer(layers, createRgbLayer(red, green, blue, false)),
          visible,
        );
      }

      if (property === 'hex') {
        return (color) => createBuilder(
          state,
          appendLayer(layers, createHexLayer(color, false)),
          visible,
        );
      }

      if (property === 'ansi256') {
        return (index) => createBuilder(
          state,
          appendLayer(layers, createAnsi256Layer(index, false)),
          visible,
        );
      }

      if (property === 'bgRgb') {
        return (red, green, blue) => createBuilder(
          state,
          appendLayer(layers, createRgbLayer(red, green, blue, true)),
          visible,
        );
      }

      if (property === 'bgHex') {
        return (color) => createBuilder(
          state,
          appendLayer(layers, createHexLayer(color, true)),
          visible,
        );
      }

      if (property === 'bgAnsi256') {
        return (index) => createBuilder(
          state,
          appendLayer(layers, createAnsi256Layer(index, true)),
          visible,
        );
      }

      if (typeof property === 'string' && Object.hasOwn(STATIC_STYLE_DEFS, property)) {
        return createBuilder(state, appendLayer(layers, createStaticLayer(property)), visible);
      }

      return Reflect.get(target, property, receiver);
    },

    set(target, property, value, receiver) {
      if (property === 'level') {
        state.level = normalizeLevel(value);
        return true;
      }

      return Reflect.set(target, property, value, receiver);
    },
  });
}

export class Chalk {
  constructor(options = {}) {
    const state = {
      level: normalizeLevel(options.level),
    };

    return createBuilder(state);
  }
}

export default Chalk;

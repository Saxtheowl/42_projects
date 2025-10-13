'use strict';

const { spawn } = require('child_process');
const { once } = require('events');
const http = require('http');
const net = require('net');
const path = require('path');

const PROJECT_ROOT = path.resolve(__dirname, '..');

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const runNode = (args, options = {}) => {
  return runCommand(process.execPath, args, options);
};

const runCommand = (command, args, { cwd = PROJECT_ROOT, env = process.env, input } = {}) => {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd,
      env,
      stdio: ['pipe', 'pipe', 'pipe']
    });

    let stdout = '';
    let stderr = '';

    child.stdout.setEncoding('utf8');
    child.stderr.setEncoding('utf8');

    child.stdout.on('data', (chunk) => {
      stdout += chunk;
    });

    child.stderr.on('data', (chunk) => {
      stderr += chunk;
    });

    child.on('error', reject);
    child.on('close', (code) => {
      resolve({ code, stdout, stderr });
    });

    if (input) {
      child.stdin.end(input);
    } else {
      child.stdin.end();
    }
  });
};

const withHttpServer = async (handler, testFn) => {
  const server = http.createServer(handler);
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const { port } = server.address();

  try {
    await testFn(port);
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
};

const getAvailablePort = () => {
  return new Promise((resolve, reject) => {
    const server = net.createServer();
    server.on('error', reject);
    server.listen(0, '127.0.0.1', () => {
      const { port } = server.address();
      server.close(() => resolve(port));
    });
  });
};

const collectSocketData = (socket) => {
  return new Promise((resolve, reject) => {
    let data = '';

    socket.setEncoding('utf8');
    socket.on('data', (chunk) => {
      data += chunk;
    });
    socket.on('end', () => resolve(data));
    socket.on('error', reject);
  });
};

const httpGet = (port, pathName) => {
  return new Promise((resolve, reject) => {
    const req = http.get(
      {
        hostname: '127.0.0.1',
        port,
        path: pathName
      },
      (res) => {
        res.setEncoding('utf8');
        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => resolve({ statusCode: res.statusCode, body: data }));
      }
    );

    req.on('error', reject);
  });
};

const ensure = (condition, message, issues) => {
  if (!condition) {
    issues.push(message);
  }
};

const testSuite = [
  async (issues) => {
    const { code, stdout } = await runNode(['ex00/hello-world.js']);
    ensure(code === 0, 'ex00 should exit with code 0.', issues);
    ensure(stdout.trim() === 'HELLO WORLD', 'ex00 should print "HELLO WORLD".', issues);
  },
  async (issues) => {
    const { code, stdout } = await runNode(['ex01/vars.js']);
    ensure(code === 0, 'ex01 should exit with code 0.', issues);
    const lines = stdout.trim().split('\n');
    const expected = [
      '42 is a string.',
      '42 is a number.',
      '42 is an object.',
      '[object Object] is an object.',
      'true is a boolean.',
      'undefined is an undefined.'
    ];
    ensure(lines.length === expected.length, 'ex01 should output six lines.', issues);
    expected.forEach((line, index) => {
      ensure(lines[index] === line, `ex01 line ${index + 1} should be "${line}".`, issues);
    });
  },
  async (issues) => {
    const { code, stdout } = await runNode(['ex02/sum_args.js', '10', '5', '-2']);
    ensure(code === 0, 'ex02 should exit with code 0.', issues);
    ensure(stdout.trim() === '13', 'ex02 should print the correct sum.', issues);
  },
  async (issues) => {
    const filePath = path.join('tests_realisation', 'fixtures', 'multiline.txt');
    const { code, stdout } = await runNode(['ex03/io.js', filePath]);
    ensure(code === 0, 'ex03 should exit with code 0.', issues);
    ensure(stdout.trim() === '3', 'ex03 should print the newline count (3).', issues);
  },
  async (issues) => {
    const filePath = path.join('tests_realisation', 'fixtures', 'multiline.txt');
    const { code, stdout } = await runNode(['ex04/asyncio.js', filePath]);
    ensure(code === 0, 'ex04 should exit with code 0.', issues);
    ensure(stdout.trim() === '3', 'ex04 should print the newline count (3).', issues);
  },
  async (issues) => {
    await withHttpServer((req, res) => {
      if (req.url === '/chunks') {
        res.write('foo');
        setTimeout(() => {
          res.write('bar');
          res.end();
        }, 20);
      } else {
        res.statusCode = 404;
        res.end();
      }
    }, async (port) => {
      const { code, stdout } = await runNode(['ex05/http-client.js', `http://127.0.0.1:${port}/chunks`]);
      ensure(code === 0, 'ex05 should exit with code 0.', issues);
      const lines = stdout.trim().split('\n');
      ensure(lines[0] === 'foo' && lines[1] === 'bar', 'ex05 should log each data chunk on its own line.', issues);
    });
  },
  async (issues) => {
    await withHttpServer((req, res) => {
      if (req.url === '/collect') {
        res.end('hello world');
      } else {
        res.statusCode = 404;
        res.end();
      }
    }, async (port) => {
      const { code, stdout } = await runNode(['ex06/http-collect.js', `http://127.0.0.1:${port}/collect`]);
      ensure(code === 0, 'ex06 should exit with code 0.', issues);
      const lines = stdout.trim().split('\n');
      ensure(lines[0] === '11', 'ex06 should print the byte length first.', issues);
      ensure(lines[1] === 'hello world', 'ex06 should print the collected data.', issues);
    });
  },
  async (issues) => {
    await withHttpServer((req, res) => {
      const respond = (body, delayMs) => {
        setTimeout(() => {
          res.end(body);
        }, delayMs);
      };

      if (req.url === '/first') {
        respond('first-response', 50);
      } else if (req.url === '/second') {
        respond('second-response', 10);
      } else if (req.url === '/third') {
        respond('third-response', 30);
      } else {
        res.statusCode = 404;
        res.end();
      }
    }, async (port) => {
      const { code, stdout } = await runNode([
        'ex07/async-http-collect.js',
        `http://127.0.0.1:${port}/first`,
        `http://127.0.0.1:${port}/second`,
        `http://127.0.0.1:${port}/third`
      ]);
      ensure(code === 0, 'ex07 should exit with code 0.', issues);
      const lines = stdout.trim().split('\n');
      ensure(
        lines[0] === 'first-response' &&
          lines[1] === 'second-response' &&
          lines[2] === 'third-response',
        'ex07 should preserve the order of the provided URLs.',
        issues
      );
    });
  },
  async (issues) => {
    const port = await getAvailablePort();
    const child = spawn(process.execPath, ['ex08/time-server.js', String(port)], {
      cwd: PROJECT_ROOT,
      stdio: ['ignore', 'pipe', 'pipe']
    });

    try {
      await delay(100);
      const socket = net.connect({ port, host: '127.0.0.1' });
      const data = (await collectSocketData(socket)).trim();
      ensure(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/.test(data), 'ex08 should return a formatted timestamp.', issues);
    } finally {
      child.kill();
      await once(child, 'exit');
    }
  },
  async (issues) => {
    const port = await getAvailablePort();
    const child = spawn(process.execPath, ['ex09/http-json-api-server.js', String(port)], {
      cwd: PROJECT_ROOT,
      stdio: ['ignore', 'pipe', 'pipe']
    });

    try {
      await delay(100);
      const iso = '2025-10-13T12:34:56.789Z';
      const parseResponse = await httpGet(port, `/api/parsetime?iso=${encodeURIComponent(iso)}`);
      ensure(parseResponse.statusCode === 200, 'ex09 /api/parsetime should respond with 200.', issues);
      const parseJson = JSON.parse(parseResponse.body);
      const expectedDate = new Date(iso);
      ensure(
        parseJson.hour === expectedDate.getUTCHours() &&
          parseJson.minute === expectedDate.getUTCMinutes() &&
          parseJson.second === expectedDate.getUTCSeconds(),
        'ex09 /api/parsetime should expose hour, minute, second from the ISO string.',
        issues
      );

      const unixtimeResponse = await httpGet(port, `/api/unixtime?iso=${encodeURIComponent(iso)}`);
      ensure(unixtimeResponse.statusCode === 200, 'ex09 /api/unixtime should respond with 200.', issues);
      const unixtimeJson = JSON.parse(unixtimeResponse.body);
      ensure(
        unixtimeJson.unixtime === expectedDate.getTime(),
        'ex09 /api/unixtime should expose the UNIX timestamp.',
        issues
      );
    } finally {
      child.kill();
      await once(child, 'exit');
    }
  }
];

const main = async () => {
  const issues = [];

  for (const test of testSuite) {
    try {
      await test(issues);
    } catch (error) {
      issues.push(`Unexpected error: ${error.message}`);
    }
  }

  if (issues.length > 0) {
    console.error('Tests failed:');
    issues.forEach((issue) => console.error(`- ${issue}`));
    process.exit(1);
  } else {
    console.log('All hello_node checks passed.');
  }
};

main();

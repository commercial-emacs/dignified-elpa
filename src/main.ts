import * as core from '@actions/core';
import * as exec from '@actions/exec';
import * as glob from '@actions/glob';
import * as path from 'path';

interface CompileOptions {
  packageDir: string;
  loadPath?: string;
}

async function byteCompile(options: CompileOptions): Promise<number> {
  const { packageDir, loadPath } = options;

  const loadPathEntries = loadPath
    ? loadPath.split(':').map(p => `(add-to-list 'load-path "${path.resolve(p)}")`).join('\n  ')
    : '';

  const compileCommand = `(byte-recompile-directory "${path.resolve(packageDir)}" 0 t)`;

  const emacsScript = `
(progn
  ${loadPathEntries}
  ${compileCommand})
`;

  core.info('Starting compilation...');
  await exec.exec('emacs', ['--batch', '--eval', emacsScript]);

  const elcGlobber = await glob.create(`${packageDir}/**/*.elc`);
  const elcFiles = await elcGlobber.glob();

  return elcFiles.length;
}

async function run(): Promise<void> {
  try {
    const options: CompileOptions = {
      packageDir: core.getInput('package-dir') || '.',
      loadPath: core.getInput('load-path')
    };

    const elcCount = await byteCompile(options);

    core.setOutput('elc-files', elcCount.toString());
    core.info(`✓ Compilation complete (${elcCount} .elc files generated)`);

  } catch (error) {
    if (error instanceof Error) {
      core.setFailed(error.message);
    }
  }
}

run();

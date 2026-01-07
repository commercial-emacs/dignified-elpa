import * as core from '@actions/core';
import * as exec from '@actions/exec';
import * as glob from '@actions/glob';
import * as path from 'path';

interface CompileOptions {
  packageFile?: string;
  packageDir: string;
  compileAll: boolean;
  loadPath?: string;
}

async function findElispFiles(dir: string): Promise<string[]> {
  const globber = await glob.create(`${dir}/**/*.el`);
  return await globber.glob();
}

async function byteCompile(options: CompileOptions): Promise<number> {
  const { packageFile, packageDir, compileAll, loadPath } = options;

  const loadPathEntries = loadPath
    ? loadPath.split(':').map(p => `(add-to-list 'load-path "${path.resolve(p)}")`).join('\n  ')
    : '';

  let compileCommand: string;

  if (compileAll) {
    compileCommand = `(byte-recompile-directory "${path.resolve(packageDir)}" 0 t)`;
  } else if (packageFile) {
    compileCommand = `(byte-compile-file "${path.resolve(packageFile)}")`;
  } else {
    const files = await findElispFiles(packageDir);
    if (files.length === 0) {
      throw new Error(`No .el files found in ${packageDir}`);
    }
    compileCommand = files.map(f => `(byte-compile-file "${f}")`).join('\n  ');
  }

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
      packageFile: core.getInput('package-file'),
      packageDir: core.getInput('package-dir') || '.',
      compileAll: core.getInput('compile-all') === 'true',
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

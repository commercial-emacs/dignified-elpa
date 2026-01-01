import * as core from '@actions/core';
import * as exec from '@actions/exec';
import * as glob from '@actions/glob';
import { promises as fs } from 'fs';
import * as path from 'path';

interface CompileOptions {
  packageFile?: string;
  packageDir: string;
  compileAll: boolean;
  loadPath?: string;
  installDeps: boolean;
}

async function checkNativeCompSupport(): Promise<boolean> {
  let output = '';
  const exitCode = await exec.exec('emacs', [
    '--batch',
    '--eval', '(princ (if (fboundp \'native-comp-available-p) (native-comp-available-p) nil))'
  ], {
    listeners: {
      stdout: (data: Buffer) => { output += data.toString(); }
    }
  });

  return exitCode === 0 && output.trim() === 't';
}

async function findElispFiles(dir: string): Promise<string[]> {
  const globber = await glob.create(`${dir}/**/*.el`);
  return await globber.glob();
}

async function installDependencies(packageFile: string): Promise<void> {
  core.info('Installing package dependencies...');

  const installScript = `
(progn
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (package-refresh-contents)
  (package-install-file "${packageFile}"))
`;

  await exec.exec('emacs', ['--batch', '--eval', installScript]);
}

async function nativeCompile(options: CompileOptions): Promise<number> {
  const { packageFile, packageDir, compileAll, loadPath } = options;

  const loadPathEntries = loadPath
    ? loadPath.split(':').map(p => `(add-to-list 'load-path "${path.resolve(p)}")`).join('\n  ')
    : '';

  let compileCommand: string;
  if (compileAll) {
    compileCommand = `(native-compile-async "${path.resolve(packageDir)}" 'recursively)`;
  } else if (packageFile) {
    compileCommand = `(native-compile "${path.resolve(packageFile)}")`;
  } else {
    const files = await findElispFiles(packageDir);
    if (files.length === 0) {
      throw new Error(`No .el files found in ${packageDir}`);
    }
    compileCommand = files.map(f => `(native-compile "${f}")`).join('\n  ');
  }

  const emacsScript = `
(progn
  (require 'comp)
  (setq native-comp-async-report-warnings-errors nil)
  (setq comp-async-report-warnings-errors nil)
  ${loadPathEntries}
  ${compileCommand}
  (while (or comp-files-queue
             (> (comp-async-runnings) 0))
    (sleep-for 1)))
`;

  core.info('Starting native compilation...');
  await exec.exec('emacs', ['--batch', '--eval', emacsScript]);

  const elnGlobber = await glob.create(`${packageDir}/**/*.eln`);
  const elnFiles = await elnGlobber.glob();

  return elnFiles.length;
}

async function run(): Promise<void> {
  try {
    const hasNativeComp = await checkNativeCompSupport();
    if (!hasNativeComp) {
      core.setFailed('This Emacs build does not support native compilation');
      return;
    }
    core.info('✓ Native compilation available');

    const options: CompileOptions = {
      packageFile: core.getInput('package-file'),
      packageDir: core.getInput('package-dir') || '.',
      compileAll: core.getInput('compile-all') === 'true',
      loadPath: core.getInput('load-path'),
      installDeps: core.getInput('install-deps') === 'true'
    };

    if (options.installDeps && options.packageFile) {
      await installDependencies(options.packageFile);
    }

    const elnCount = await nativeCompile(options);

    core.setOutput('eln-files', elnCount.toString());
    core.info(`✓ Native compilation complete (${elnCount} .eln files generated)`);

  } catch (error) {
    if (error instanceof Error) {
      core.setFailed(error.message);
    }
  }
}

run();

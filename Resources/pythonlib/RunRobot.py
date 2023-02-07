#!/usr/bin/env python
import shutil
import argparse
import sys

from robot import run_cli, rebot_cli
from os import listdir, remove
from os.path import isfile, join

"""
The script takes the argument file and looks for lines containing --suite, when found a list is constructed
with all configured parameter following until a new --suite is found. The process starts over
and eventually the different lists are executed in separate robot commands. The reports are stored in a temp directory
after which rebot_cli() combines the files. Finally the files are moved to the Results directory.
"""""
original_dir = './Results/original/'
output_dir = './Results/'

standard_command = ['--outputdir', original_dir, '--timestampoutputs']
argument_names_to_parse = ['--include', '--exclude', '--variable']

def main(args):

    with open('./' + args.argumentfile, 'r') as f:
        lines = f.readlines()
        lines = [line.rstrip().rstrip('\t').rstrip(' ') for line in lines]

        arguments_list = []
        j = 0

        # you can add Robot variables to be parsed in the following list:
        for line in lines:
            if line and '#' not in line:
                if '--suite' in line:
                    if j > 0:
                        arguments_list.append(suite_line)
                    suite_line = [line.split()[0], line.split()[1]]
                    j += 1

                for arg in argument_names_to_parse:
                    if arg in line:
                            suite_line.append(arg)
                            suite_line.append(line.replace(arg, '').strip().strip('\t'))

        try:
            arguments_list.append(suite_line)
        except UnboundLocalError as e:
            print('ERROR, please make sure there is at least one --suite line in the argument file', e)
            sys.exit(1)

        print('The suites with arguments that are going to be run are:')
        for suite in arguments_list:
            print(' '.join(suite))

    return_codes = []
    for x, suite in enumerate(arguments_list):
        command = standard_command + suite + ['Tests']
        return_codes.append(run_cli(command, exit=False))

    return max(return_codes)


def run_rebot():

    all_files = [f for f in listdir(original_dir) if isfile(join(original_dir, f))]

    xml_output_files = [original_dir + f for f in all_files if '.xml' in f and 'output' in f]

    print('\nThe combined Robot output files can be found here:')
    return rebot_cli(['--outputdir', output_dir, '--xunit', './output.xml', '--timestampoutputs', '--merge']
                     + xml_output_files, exit=False)


def empty_original_dir():
    all_files = [join(original_dir, f) for f in listdir(original_dir) if isfile(join(original_dir, f))
                 and 'gitkeep' not in f]
    for file in all_files:
        remove(file)


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--argumentfile', '-A', help='The argument file to process', type=str)
    arguments = parser.parse_args()

    # removing old files:
    empty_original_dir()
    # run scripts:
    rc = main(arguments)
    # combine output files
    run_rebot()

    sys.exit(rc)

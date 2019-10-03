#!/bin/sh

usage () {
    # usage information
    echo "$(basename "$0") [ARGUMENTS] -- a bash wrapper for PEXO software (https://github.com/phillippro/pexo). See documentation for full reference."
    echo
    echo "Arguments:"
    echo
    echo "    -m,--mode	       PEXO mode: emulate or fit [optional; default=emulate]"
    echo
    echo "    -c,--component     PEXO model component: timing (T), astrometry (A), radial velocity (R) and their combinations [optional; default=TAR]"
    echo
    echo "    -t,--time	       Two options are possible. 1. Timing file: epochs or times could be in 1-part or 2-part JD[UTC] format; 2. Format of \"Start End By\" [mandatory if mode=emulate]"
    echo
    echo "    -p,--par	       Parameter file: parameters for models, observatory, for Keplerian/binary motion [mandatory]"
    echo
    echo "    -v,--var	       Output variables [optional; default=NULL]"
    echo
    echo "    -o,--out	       Output file name: relative or absolute path [optional; default=out.txt]"
    echo
    echo "    -f,--figure	       Output figure and verbose: FALSE or TRUE [optional; default= TRUE]"
    echo
    echo "    -h,--help          show this help text"
}


# parse arguments, consistent with pexo.R
while [ $# -gt 0 ]
do
    key="$1"
    case $key in
        -m|--mode)
        mode="$2"
        shift # past argument
        shift # past value
        ;;
        -c|--component)
        component="$2"
        shift # past argument
        shift # past value
        ;;
        -t|--time)
        time="$2"
        shift # past argument
        shift # past value
        ;;
        -p|--par)
        par="$2"
        shift # past argument
        shift # past value
        ;;
        -v|--var)
        var="$2"
        shift # past argument
        shift # past value
        ;;
        -o|--out)
        out="$2"
        shift # past argument
        shift # past value
        ;;
        -f|--figure)
        figure="$2"
        shift # past argument
        shift # past value
        ;;
        -h|--help)
        usage
        exit 0
        ;;
        *)    # unknown option
        echo "Unknown option: $1"
        echo "Run 'pexo.sh --help' to see available arguments."
        exit 1 # past argument
        ;;
    esac
done

# check if R is installed
rscript=$(which Rscript)
if [ -z "$rscript" ]
then
    echo "Error: \$Rscript is not installed. Exiting."
    exit 1
else
    echo "Found Rscript in $rscript"
fi

# check if the PEXODIR variable is set
if [ -z "$PEXODIR" ]
then
    echo "Error: \$PEXODIR is not set. It should point to PEXO repository. Exiting."
    exit 1
else
    echo "Found PEXO in $PEXODIR"
fi

# save current path
original_path="$PWD"

# convert input paths to absolute
time=$(realpath $time 2>/dev/null)
par=$(realpath $par 2>/dev/null)
out=$(realpath $out 2>/dev/null)

# go to pexo code
cd $PEXODIR
cd "code"

# base command
# command="$rscript pexo.R"
command="Rscript pexo.R"

# add parameters (could do with a function here, but bash functions and strings don't mix well)
if [ ! -z "$mode" ]
then
    command="$command -m $mode"
fi

if [ ! -z "$component" ]
then
    command="$command -c $component"
fi

if [ ! -z "$time" ]
then
    command="$command -t $time"
fi

if [ ! -z "$par" ]
then
    command="$command -p $par"
fi

if [ ! -z "$var" ]
then
    command="$command -v $var"
fi

if [ ! -z "$out" ]
then
    command="$command -o $out"
fi

if [ ! -z "$figure" ]
then
    command="$command -f $figure"
fi


# run PEXO
echo "---------------------------------"
$command

# go back to the original directory
cd $original_path
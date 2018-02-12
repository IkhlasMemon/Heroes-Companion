# if any command fails at any point, quit
set -e

# Check working directory and exit if bad
DIR="$(basename $(pwd) )"
if [ $DIR != 'scripts' ]; then
    echo "In /$DIR"
    echo "This must be run from inside the /scripts directory"
    exit 1
fi

find ../assets/ -type f -name "*.png" > ls.txt
# Replace the start of a line ../ with four spaces and a -
cat ls.txt | sed 's/^..\//    - /;s/\/\//\//' > ls2.txt
rm ls.txt
mv ls2.txt ls.txt 

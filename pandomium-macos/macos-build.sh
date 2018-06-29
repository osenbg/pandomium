#
# macOS x64
#
# Requirements:
#   Git
#   CMake
#   Xcode
#   Apache Ant
#   Python 2.7 added to PATH
#   JDK 8 (* > 8u121) added to PATH
#

mkdir JCEF67 && cd JCEF67
git clone https://bitbucket.org/chromiumembedded/java-cef.git src && cd src

# Modify sources
find ./java/org -type f -exec sed -i 's/ protected / public /g' {} +
find ./java/org -type f -exec sed -i 's/ private / public /g' {} +
find ./java/org -type f -exec sed -i 's/ final /  /g' {} +

# Modification fixes
find ./java/org -type f -exec sed -i 's/public TransitionFlags(/TransitionFlags(/g' {} +
find ./java/org -type f -exec sed -i 's/public TransitionType(/TransitionType(/g' {} +

# Build natives
mkdir jcef_build && cd jcef_build
cmake -G "Xcode" -DPROJECT_ARCH="x86_64" ..

# Open jcef.xcodeproj in Xcode
# - Select Scheme > Edit Scheme and change the "Build Configuration" to "Release"
# - Select Product > Build. Then:
cd ../tools/

# Create binary distrib
./make_distrib.bat macosx64

cd ../..
mkdir macosx64
cd src/binary_distrib/macosx64/bin

# Create fat jar
mkdir jcef-macosx64
(cd jcef-macosx64; unzip -uo ../gluegen-rt.jar)
(cd jcef-macosx64; unzip -uo ../gluegen-rt-natives-macosx-universal.jar)
(cd jcef-macosx64; unzip -uo ../jcef.jar)
(cd jcef-macosx64; unzip -uo ../jogl-all.jar)
(cd jcef-macosx64; unzip -uo ../jogl-all-natives-macosx-universal.jar)
jar -cvf jcef-macosx64.jar -C jcef-macosx64 .

# Move output
cd ../../../../
cp src/binary_distrib/macosx64/bin/jcef-macosx64.jar macosx64/jcef-macosx64.jar
cp -r src/binary_distrib/macosx64/bin/lib/macosx64 macosx64/natives
mkdir -p macosx64/src/org && cp -r src/java/org macosx64/src/org

# Pack natives
cd macosx64/natives/ && tar -cf - . | xz -9e -c - > ../../macosx64/macosx64-natives.tar.xz && cd -

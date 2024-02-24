#!/usr/bin/env bash

GENERATION_PATH=.generated/ios

ARM64_LIB_PATH=../target/aarch64-apple-ios/release/libprisma_client_uniffi_example.dylib
ARM64_SIM_LIB_PATH=../target/aarch64-apple-ios-sim/release/libprisma_client_uniffi_example.dylib
X86_LIB_PATH=../target/x86_64-apple-ios/release/libprisma_client_uniffi_example.dylib
SIM_LIB_PATH=../target/ios-simulator/libprisma_client_uniffi_example.dylib

IOS_PATH=platforms/ios
TOOLS_PATH="${IOS_PATH}/tools"

SWIFT_PACKAGE_PATH="${IOS_PATH}/lib/PrismaExample"
SWIFT_BINDINGS_FILE_PATH="${SWIFT_PACKAGE_PATH}/Sources/prisma-client-uniffi/prisma_client_uniffi_example.swift"

XCFRAMEWORK_PATH="${SWIFT_PACKAGE_PATH}/prisma_client_uniffi_exampleFFI.xcframework"
XCFRAMEWORK_SIM_PATH="${XCFRAMEWORK_PATH}/ios-arm64_x86_64-simulator/prisma_client_uniffi_exampleFFI.framework"
XCFRAMEWORK_SIM_HEADERS_PATH="${XCFRAMEWORK_SIM_PATH}/Headers"
XCFRAMEWORK_SIM_MODULES_PATH="${XCFRAMEWORK_SIM_PATH}/Modules"
XCFRAMEWORK_SIM_LIBRARY_PATH="${XCFRAMEWORK_SIM_PATH}/prisma_client_uniffi_exampleFFI"
XCFRAMEWORK_ARM64_PATH="${XCFRAMEWORK_PATH}/ios-arm64/prisma_client_uniffi_exampleFFI.framework"
XCFRAMEWORK_ARM64_HEADERS_PATH="${XCFRAMEWORK_ARM64_PATH}/Headers"
XCFRAMEWORK_ARM64_MODULES_PATH="${XCFRAMEWORK_ARM64_PATH}/Modules"
XCFRAMEWORK_ARM64_LIBRARY_PATH="${XCFRAMEWORK_ARM64_PATH}/prisma_client_uniffi_exampleFFI"

# Build libraries for each platform
cargo build -p prisma-client-uniffi-example --release --target aarch64-apple-ios
cargo build -p prisma-client-uniffi-example --release --target aarch64-apple-ios-sim
cargo build -p prisma-client-uniffi-example --release --target x86_64-apple-ios

# # Merge x86 and simulator arm libraries with lipo
mkdir -p target/ios-simulator
lipo -create $X86_LIB_PATH $ARM64_SIM_LIB_PATH -output $SIM_LIB_PATH

# # Remove previous artefacts and files
rm -rf $XCFRAMEWORK_PATH
rm -f $SWIFT_BINDINGS_FILE_PATH
rm -rf $GENERATION_PATH

# Generate headers & Swift bindings
#
# Note: swiftformat is automatically run by uniffi-bindgen if available
if ! command -v swiftformat &> /dev/null
then
    echo "swiftformat could not be found"
    exit 1
fi
mkdir -p $GENERATION_PATH
cargo uniffi-bindgen generate --library $ARM64_LIB_PATH -l swift --out-dir $GENERATION_PATH

mkdir -p ${GENERATION_PATH}/headers
mv ${GENERATION_PATH}/*.h ${GENERATION_PATH}/headers/
mv ${GENERATION_PATH}/*.modulemap ${GENERATION_PATH}/headers/module.modulemap
mv ${GENERATION_PATH}/*.swift ${SWIFT_PACKAGE_PATH}/Sources/prisma-client-uniffi/
xcodebuild -create-xcframework \
  -library ${ARM64_LIB_PATH} \
  -headers ${GENERATION_PATH}/headers \
  -library ${ARM64_SIM_LIB_PATH} \
  -headers ${GENERATION_PATH}/headers \
  -output ${SWIFT_PACKAGE_PATH}/prisma_client_uniffi_exampleFFI.xcframework

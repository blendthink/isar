#!/bin/sh

script_dir=$(cd "$(dirname "$0")"; pwd -P)

tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'tmpdir')
core_version=`dart $script_dir/get_version.dart`

echo $core_version

cd $tmp_dir

git clone https://github.com/isar/isar-core.git
cd isar-core
git checkout tags/$core_version
git submodule update --init

cd dart-ffi

cargo install cbindgen
cbindgen --config $script_dir/cbindgen.toml --crate isar --output $script_dir/../isar-dart.h

cd $script_dir/../

echo "$(cat isar-dart.h)"

dart pub get
dart run ffigen --config tool/ffigen.yaml
rm isar-dart.h

dart format --fix lib/src/native/bindings.dart

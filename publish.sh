#!/bin/sh -x
#dartfmt -w .
dart format --fix .
dart pub publish

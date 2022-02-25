#!/usr/bin/env bash

tar -zcvf json_partner.tar.gz bin analysis_options.yaml CHANGELOG.md LICENSE pubspec.lock pubspec.yaml README.md

curl --location --request POST 'https://pub.youzi.dev/api/api/packages/versions/newUpload' --form 'file=@"`pwd`/json_partner.tar.gz"'


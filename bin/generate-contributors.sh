#!/bin/bash
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
cd `dirname $0`/..

SHORTLOG=$(tempfile)
CONTRIBUTORS_HTML=$(tempfile)

for version in $(cat docs/site/home/template/downloads.html | grep -Po '(?<=<strong>).*(?=</strong>)' | grep -P '^[0-9]+\.[0-9]+\.[0-9]+'); do
  prev=$(perl -pe 's/^((\d+\.)*)(\d+)(.*)$/$1.($3-1).$4/e' <<< ${version})
  prev=`git tag | grep -Fx "${prev}"`
  if [ -z ${prev} ]; then
    case ${version} in
      3.4.0)
        prev='3.3.5'
        ;;
      3.3.0)
        prev='3.2.6'
        ;;
      3.2.1)
        prev='3.2.0-incubating'
        ;;
      3.1.3)
        prev='3.1.2-incubating'
        ;;
      3.2.0-incubating)
        prev='3.1.2-incubating'
        ;;
      3.1.0-incubating)
        prev='3.0.2-incubating'
        ;;
      3.0.0-incubating)
        prev=''
        ;;
      *)
        prev='unknown'
        ;;
    esac
  fi
  if [ "${prev}" != 'unknown' ]; then
    _version=`tr '.' '_' <<< ${version}`
    if [ "${prev}" != '' ]; then
      prev="${prev}.."
    fi
    echo "$(git shortlog -sn ${prev}${version})</code></pre>" > ${SHORTLOG}
    cat docs/site/home/template/contributors.html | sed -e "s/!!!VERSION!!!/${version}/g"   \
                                                        -e "s/!!!_VERSION!!!/${_version}/g" \
                                                        -e "s/!!!PREV_VERSION!!!/${prev}/g" \
                                                        -e "/!!!SHORTLOG!!!/ r ${SHORTLOG}" \
                                                        -e "/!!!SHORTLOG!!!/d" >> ${CONTRIBUTORS_HTML}
  else
    >&2 echo "Predecessor of version ${version} is unkown (add it manually in $(basename $0))"
  fi
  sed -e "/!!!CONTRIBUTORS!!!/ r ${CONTRIBUTORS_HTML}" -e "/!!!CONTRIBUTORS!!!/d" docs/site/home/template/downloads.html > docs/site/home/downloads.html
done

rm -f ${CONTRIBUTORS_HTML} ${SHORTLOG}

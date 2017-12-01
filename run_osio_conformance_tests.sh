#!/bin/bash

################################################################################################
#  Copyright © 2017 Copyright Red Hat Inc. and/or its affiliates and other contributors
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
################################################################################################

echo "/usr/local/bin/osio.test --ginkgo.v --ginkgo.noColor=true | tee ${RESULTS_DIR}/osio-conformance.log"
/usr/local/bin/osio.test --ginkgo.v --ginkgo.noColor=true | tee ${RESULTS_DIR}/osio-conformance.log

# tar up the results for transmission back
cd ${RESULTS_DIR}
tar -czf osio-conformance.tar.gz *

# mark the done file as a termination notice.
echo -n ${RESULTS_DIR}/osio-conformance.tar.gz > ${RESULTS_DIR}/done

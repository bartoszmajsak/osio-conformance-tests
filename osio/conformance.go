package osio

import (
	"testing"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"os"
	"github.com/golang/glog"
	"github.com/onsi/ginkgo/reporters"
	"fmt"
	"github.com/onsi/ginkgo/config"
	"path"
)

type TestSetupType struct {
	ReportDir    		string
	ReportPrefix 		string
}

var TestSetup TestSetupType

func ExecuteTests(t *testing.T) {

	var r []Reporter
	if TestSetup.ReportDir != "" {
		if err := os.MkdirAll(TestSetup.ReportDir, 0755); err != nil {
			glog.Errorf("Failed creating report directory: %v", err)
		} else {
			r = append(r, reporters.NewJUnitReporter(path.Join(TestSetup.ReportDir, fmt.Sprintf("junit_%v%02d.xml", TestSetup.ReportPrefix, config.GinkgoConfig.ParallelNode))))
		}
	}
	glog.Infof("Starting OSIO conformance tests")
	RegisterFailHandler(Fail)
	RunSpecsWithDefaultAndCustomReporters(t, "OSIO conformance test suite", r)
}
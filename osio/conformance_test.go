package osio

import (
	"testing"
	"flag"
)


func init()  {
	flag.StringVar(&TestSetup.ReportDir, "report-dir", "", "Path to the directory where the JUnit XML reports should be saved. Default is empty, which doesn't generate these reports.")
	flag.Parse()
}

func TestCluster(t *testing.T) {
	ExecuteTests(t)
}



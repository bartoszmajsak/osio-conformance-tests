package osio

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"github.com/openshift/client-go/oauth/clientset/versioned"
	oauth "github.com/openshift/api/oauth/v1"
	metaV1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/rest"
)

var _ = Describe("OpenShift OAuth", func() {

	var (
		client *versioned.Clientset
		err error
	)

	BeforeSuite(func() {
		config, e := rest.InClusterConfig()
		if e != nil {
			panic(e.Error())
		}
		client, err = versioned.NewForConfig(config)
		if err != nil {
			panic(err.Error())
		}
	})

	Context("Registered Clients", func() {
		It("should have oauth client named openshift-io registered", func() {
			oAuthClient, err := client.OauthV1().OAuthClients().Get("openshift-io", metaV1.GetOptions{})
			if err !=  nil {
				panic(err.Error())
			}

			Ω(oAuthClient.Name).Should(Equal("openshift-io"))
		})

		It("should have oauth client named openshift-io registered with redirect to https://sso.openshift.io", func() {
			oAuthClient, err := client.OauthV1().OAuthClients().Get("openshift-io", metaV1.GetOptions{})
			if err !=  nil {
				panic(err.Error())
			}

			GetRedirects := func(o *oauth.OAuthClient) []string {
				return o.RedirectURIs
			}

			Ω(oAuthClient).Should(WithTransform(GetRedirects, ContainElement("https://sso.openshift.io")))
		})
	})

})

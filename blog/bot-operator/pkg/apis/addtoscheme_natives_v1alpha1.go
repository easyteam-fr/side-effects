package apis

import (
	"github.com/easyteam-fr/side-effects/blog/bot-operator/pkg/apis/natives/v1alpha1"
)

func init() {
	// Register the types with the Scheme so the components can map objects to GroupVersionKinds and back
	AddToSchemes = append(AddToSchemes, v1alpha1.SchemeBuilder.AddToScheme)
}

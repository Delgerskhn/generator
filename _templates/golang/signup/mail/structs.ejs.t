---
to: "<%= path ? `${path}/mail/structs.go` : `${cwd}/src/services/mail/structs.go` %>"
---
package mail

type (
	EmailType string

	EmailInput struct {
		Email    string    `json:"email"`
		Subtitle string    `json:"subtitle"`
		Type     EmailType `json:"type"`
	}

	SignUpActivation struct {
		Code string `json:"code"`
	}
)

const (
	EmailTypeSignUpActivation EmailType = "signup_activation"
)

---
to: "<%= path ? `${path}/mail/client.go` : `${cwd}/src/services/mail/client.go` %>"

---
package gmail


type Client struct {
	From     string
	Password string
	SmtpHost string
	SmtpPort string
}

func InitMail() *Client {
	return &Client{
		From:     viper.GetString("NOREPLY_EMAIL"),
		Password: viper.GetString("NOREPLY_EMAIL_PASSWORD"),
		SmtpHost: "smtp.gmail.com",
		SmtpPort: "587",
	}
}

func (c Client) Send(input EmailInput, params interface{}) error {
	t, errTemp := template.ParseFiles(fmt.Sprintf("files/mail/%s.html", input.Type))
	if errTemp != nil {
		fmt.Println("PARSING TEMPLATE ERROR : ", errTemp.Error())
		return errTemp
	}

	var body bytes.Buffer

	mimeHeaders := "MIME-version: 1.0;\nContent-Type: text/html; charset=\"UTF-8\";\n\n"
	body.Write([]byte(fmt.Sprintf("Subject: %s \n%s\n\n", input.Subtitle, mimeHeaders)))

	t.Execute(&body, params)
	auth := smtp.PlainAuth("", c.From, c.Password, c.SmtpHost)

	// Sending email.
	err := smtp.SendMail(c.SmtpHost+":"+c.SmtpPort, auth, c.From, []string{input.Email}, body.Bytes())
	if err != nil {
		return err
	}
	log.Println("Mail sent successfully")
	return nil
}

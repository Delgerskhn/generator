---
to: "<%= path ? `${path}/mail/client.go` : `${cwd}/src/services/mail/client.go` %>"
---
package mail


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
		SmtpHost: viper.GetString("NOREPLY_EMAIL_HOST"),
		SmtpPort: "465",
	}
}

func (c Client) Send(input EmailInput, params interface{}) error {
	t, _ := template.ParseFiles(fmt.Sprintf("files/mail/%s.html", input.Type))

	tlsconfig := &tls.Config{
		InsecureSkipVerify: true,
		ServerName:         c.SmtpHost,
	}
	auth := smtp.PlainAuth(c.From, c.From, c.Password, c.SmtpHost)
	conn, err := tls.Dial("tcp", c.SmtpHost+":"+c.SmtpPort, tlsconfig)
	if err != nil {
		log.Panic(err)
	}

	client, err := smtp.NewClient(conn, c.SmtpHost)
	if err != nil {
		log.Panic(err)
	}

	if err = client.Auth(auth); err != nil {
		log.Panic(err)
	}

	if err = client.Mail(c.From); err != nil {
		log.Panic(err)
	}

	if err = client.Rcpt(input.Email); err != nil {
		log.Panic(err)
	}

	w, err := client.Data()
	if err != nil {
		log.Panic(err)
	}

	var body bytes.Buffer

	subject := " (Magic Store)"

	mimeHeaders := "MIME-version: 1.0;\nContent-Type: text/html; charset=\"UTF-8\";\n\n"
	body.Write([]byte(fmt.Sprintf("From: %s\r\nTo: %s\r\nSubject: %s \n%s\n\n", c.From, input.Email, input.Subtitle+subject, mimeHeaders)))

	t.Execute(&body, params)
	_, err = w.Write(body.Bytes())
	if err != nil {
		log.Panic(err)
	}
	// Sending email.
	err = w.Close()
	if err != nil {
		log.Panic(err)
	}

	client.Quit()

	log.Println("Mail sent successfully")
	return nil
}

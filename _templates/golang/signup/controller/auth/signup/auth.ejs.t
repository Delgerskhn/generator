---
to: "<%= path ? `${path}/signup/auth.go` : `${cwd}/src/signup/auth.go` %>"
---
package controllers


type AuthController struct {
	base.Controller
}

func (co AuthController) Register(router *gin.RouterGroup) {
	authRouter := router.Group("/")
	authRouter.POST("send_otp", co.SendOTP)
	authRouter.POST("activate_otp", co.ActivateOTP)
	authRouter.POST("signup", co.Singup)
}

type (
	SignUpInput struct {
		UUID         string `json:"uuid"`
		Email        string `json:"email"`
		EmailOTPCode string `json:"email_opt_code"`
		Password     string `json:"password"`
	}
	LoginResponse struct {
		Token string         `json:"token"`
		User  databases.User `json:"user"`
	}
)

//	@Summary	Бүртгүүлэх
//	@Tags		Auth
//	@Param		input	body		SignUpInput	false	"Filter"
//	@Success	200		{object}	base.ResponseBody{body=LoginResponse}
//	@Router		/auth/signup [post]
func (co AuthController) Singup(c *gin.Context) {
	defer func() {
		c.JSON(co.GetBody())
	}()

	var params SignUpInput
	if err := c.ShouldBindJSON(&params); err != nil {
		co.SetError(http.StatusBadRequest, err.Error())
		return
	}

	redisKey := fmt.Sprintf("email_opt_activated_%s_%s", params.UUID, params.Email)
	value, err := co.Redis.Get(redis.CTX, redisKey).Result()
	if err != nil {
		co.SetError(http.StatusInternalServerError, "Email-ээ баталгаажуулана уу")
		return
	}

	if value != params.EmailOTPCode {
		co.SetError(http.StatusInternalServerError, "Таны бүртгэлийн хугцаа дууссан дахин оролдоно уу")
		return
	}

	hashedPass, err := utils.GenerateHash(params.Password)
	if err != nil {
		co.SetError(http.StatusInternalServerError, err.Error())
		return
	}

	instance := databases.User{
		Email:    params.Email,
		Password: hashedPass,
	}

	if err := co.DB.Create(&instance).Error; err != nil {
		if strings.ContainsAny(err.Error(), "unique constraint") || strings.ContainsAny(err.Error(), "duplicate key") || strings.Contains(err.Error(), "unique constraint") || strings.Contains(err.Error(), "duplicate key") {
			co.SetError(http.StatusBadRequest, "Таны утас эсвэл имэйл аль хэдийн бүртгэлтэй байна.")
		} else {
			co.SetError(http.StatusInternalServerError, err.Error())
		}
		return
	}

	co.SetBody(LoginResponse{
		Token: utils.GenerateToken(utils.TokenClaims{ID: instance.ID}),
		User:  instance,
	})
}

type (
	SendOPTInput struct {
		UUID  string `json:"uuid"`
		Email string `json:"email"`
	}
)

//	@Summary	OTP илгээх
//	@Tags		Auth
//	@Param		input	body		SendOPTInput	false	"Filter"
//	@Success	200		{object}	base.ResponseBody{body=base.SuccessResponse}
//	@Router		/auth/send_otp [post]
func (co AuthController) SendOTP(c *gin.Context) {
	defer func() {
		c.JSON(co.GetBody())
	}()

	var params SendOPTInput
	if err := c.ShouldBindJSON(&params); err != nil {
		co.SetError(http.StatusBadRequest, err.Error())
		return
	}

	code := utils.RandomNumber(6)
	fmt.Println(fmt.Sprintf("email_opt_%s_%s", params.UUID, params.Email), code)

	set, err := co.Redis.SetNX(redis.CTX, fmt.Sprintf("email_opt_%s_%s", params.UUID, params.Email), code, 60*time.Second).Result()
	if err != nil {
		co.SetError(http.StatusInternalServerError, err.Error())
		return
	}
	if !set {
		co.SetError(http.StatusInternalServerError, "Redis connection timeout")
		return
	}
	value, err := co.Redis.Get(redis.CTX, fmt.Sprintf("email_opt_%s_%s", params.UUID, params.Email)).Result()
	if err != nil {
		co.SetError(http.StatusInternalServerError, err.Error())
		return
	}

	fmt.Println("value:::", value)
	if err := co.Mail.Send(mail.EmailInput{Email: params.Email, Subtitle: "activate your email", Type: mail.EmailTypeSignUpActivation}, mail.SignUpActivation{
		Code: code,
	}); err != nil {
		co.SetError(http.StatusInternalServerError, err.Error())
		return
	}

	co.SetBody(base.SuccessResponse{Success: true})
}

type (
	ActivateOPTInput struct {
		UUID  string `json:"uuid"`
		Email string `json:"email"`
		Code  string `json:"code"`
	}
)

//	@Summary	OTP баталгаажуулах
//	@Tags		Auth
//	@Param		input	body		ActivateOPTInput	false	"Filter"
//	@Success	200		{object}	base.ResponseBody{body=base.SuccessResponse}
//	@Router		/auth/activate_otp [post]
func (co AuthController) ActivateOTP(c *gin.Context) {
	defer func() {
		c.JSON(co.GetBody())
	}()

	var params ActivateOPTInput
	if err := c.ShouldBindJSON(&params); err != nil {
		co.SetError(http.StatusBadRequest, err.Error())
		return
	}

	value, err := co.Redis.Get(redis.CTX, fmt.Sprintf("email_opt_%s_%s", params.UUID, params.Email)).Result()
	if err != nil {
		co.SetError(http.StatusInternalServerError, "OTP code expired")
		return
	}

	if params.Code != value {
		co.SetError(http.StatusBadRequest, "OTP code mismatch")
		return
	}

	set, err := co.Redis.SetNX(redis.CTX, fmt.Sprintf("email_opt_activated_%s_%s", params.UUID, params.Email), params.Code, time.Hour).Result()
	if err != nil {
		co.SetError(http.StatusInternalServerError, err.Error())
		return
	}
	if !set {
		co.SetError(http.StatusInternalServerError, "Redis connection timeout")
		return
	}

	co.SetBody(base.SuccessResponse{Success: true})
}

---
to: "<%= path ? `${path}/signup/signup_activation.html` : `${cwd}/src/signup/signup_activation.html` %>"
---
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>SignUp Activation</title>
  </head>
  <body>
    Your activation code: {{.Code}}
  </body>
</html>

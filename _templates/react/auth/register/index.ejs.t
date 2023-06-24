---
to: "<%= path ? `${path}/index.tsx` : `${cwd}/src/auth/pages/register/index.tsx` %>"
---
import { ProForm, ProFormText } from "@ant-design/pro-components";
import { Button, message } from "antd";
import "./style.css";
import { useRequest } from "ahooks";
import auth from "../../service";
export const RegisterPage = () => {
  const emailRegisterValidation = useRequest(auth.gmailValidation, {
    manual: true,
    onError: (err) => message.error(err.message),
  });

  return (
    <div className="container">
      <ProForm
        className="form"
        submitter={{
          render: () => (
            <Button
              block
              type="primary"
              htmlType="submit"
              size="large"
              className="mt-7 "
            >
              Sign In
            </Button>
          ),
        }}
      >
        <ProFormText
          label="Email"
          placeholder={"Type ..."}
          fieldProps={{
            addonAfter: <Button type="primary">Send</Button>,
          }}
        />
        <ProFormText label="Code" placeholder={"Type ..."} />
      </ProForm>

      <div
        style={{
          position: "fixed",
          bottom: 40,
          left: "50%",
          transform: "translate(-50%, 0)",
        }}
      >
        <p className="text-center ">
          <span
            style={{
              fontSize: "1rem",
              color: "white",
              fontFamily: "Inter",
            }}
          >
            ©{new Date().getFullYear()} Powered by{" "}
            <a
              style={{ cursor: "pointer", color: "white", fontWeight: 600 }}
              href="https://techpartners.asia"
              target="_blank"
              rel="noreferrer"
            >
              “Tech Partners” LLC
            </a>
          </span>
        </p>
      </div>
    </div>
  );
};

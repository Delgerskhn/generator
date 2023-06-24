---
to: "<%= path ? `${path}/form.tsx` : `${cwd}/src/auth/pages/register/form.tsx` %>"
---

import { ProForm, ProFormText } from "@ant-design/pro-components";
import { Button } from "antd";

export const RegisterForm = () => {
  return (
    <ProForm
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
  );
};

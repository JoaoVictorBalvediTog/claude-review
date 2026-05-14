# Review Input

This file is exactly the context passed to Claude through stdin.

Generated at: 2026-05-13T21:25:58Z

---
# Pull Request Context

- PR title: fix: RER-486 correcting signup displaying success on status 400
- PR URL: https://github.com/Adtango-Media/reach-social-front-end/pull/130
- Head branch: fix/RER-486-signup-false-success-error
- Base branch: staging
- Author: JoaoVictorBalvediTog
- Changed files: 1
- Additions: 20
- Deletions: 4

## PR Body

No PR body provided.

---
# Jira Context

- Jira key: RER-486
- Status: FETCHED
- Summary: Signup – False success toast displayed on API validation failure (400)
- Issue type: Bug
- Workflow status: Code Review
- Priority: Medium
- Assignee: João Victor Balvedi
- Reporter: Eduardo Demartini Giacomini
- Labels: None
- Components: None
- Fix versions: None

## Description

Description
On the Sign Up screen, after submitting the form, a green success toast — "Account created! Please check your email to get your temporary password." — is displayed to the user. However, the network request actually fails with a 400 Validation failed error (Full name is not in a valid format → at fullName), the user is not created, and the page does not redirect.
Context: The form collects First name and Last name as separate fields, but the API appears to expect a combined fullName field. The frontend is not correctly assembling or validating this before submission, causing the API to reject it — while the UI incorrectly treats the response as a success.
Steps to Reproduce
Go to /auth/signup

Fill in First name (e.g. test) and Last name (e.g. 123)

Enter a valid email and check the Terms checkbox

Click Sign up

Expected vs Actual
Expected: If the request fails, no success toast should be shown. The user should see an error message and remain on the form to correct the input. If it succeeds, the user should be created and redirected accordingly.
Actual: A success toast is displayed even though the API returns 400 - Validation failed: Full name is not in a valid format. The user is not created and stays on the signup page with no error feedback.

---
# Application Context

- Status: CONFIGURED
- Base ref used: staging
- Files requested: README.md

## README.md

\```text

# Reach Social Front-End

This is a front-end project built with [Next.js](https://nextjs.org), created using `create-next-app`. It uses TypeScript, Chakra UI, React Hook Form, TanStack Table, and other modern libraries from the React ecosystem. It serves as the user interface for the Reach Social system.

---

## 🔧 Technologies & Libraries

- **Next.js 15** – Modern React framework for web applications
- **React 19** – Core UI library
- **Chakra UI** – Component library for styling
- **React Hook Form + Zod** – Form management with schema validation
- **Next Auth** – Authentication system
- **Axios** – HTTP requests
- **Biome** – Code formatter and linter

---

## 🚀 Getting Started

```bash
git clone git@github.com:Adtango-Media/reach-social-front-end.git
cd reach-social-front-end
npm install
cp .env.example .env
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view it in your browser.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

---

## 📁 Project Structure

```txt
src/
│
├── @types/                     # Global/custom TypeScript types
│   └── next-auth.d.ts
│
├── auth/                       # Authentication logic (middleware, utils, enums)
│
├── components/                 # Reusable and domain-specific components
│
├── contexts/                   # React context providers (session, drawer, etc.)
│
├── layouts/                    # Reusable layout components
│
├── lib/                        # Utilities and Axios instances
│
├── pages/                      # Application pages and routes
│   ├── index.tsx               # Home page
│
├── styles/                     # Theme and style configurations (Chakra)
│
└── utils/                      # Utility functions (formatting CPF/CNPJ, currency, etc.)

public/
└── assets/                     # Static files, logos, and images
```

---

## 📜 Available Scripts

| Script        | Description                                               |
|---------------|-----------------------------------------------------------|
| `dev`         | Start development server                                  |
| `build`       | Compile the app for production                            |
| `start`       | Start the production server                               |
| `lint`        | Run Biome linter and fix issues                           |
| `format`      | Format code using Biome                                   |

---

## 📦 Environment Variables

Environment variables are defined in `.env.local` for settings such as:

```

```

> **Note:** Never commit `.env.local` to version control. Use a `.env.example` file for reference.

---

## ✅ Linting & Formatting

This project uses [Biome](https://biomejs.dev/) for code linting and formatting.

```bash
npm run lint   # Auto-fix lint issues
npm run format # Format code consistently
```

---

## 🔀 GitFlow

This project follows the **GitFlow** branching model:

- `main`: Stable production branch.
- `staging`: Main integration branch for ongoing development.
- `feature/feature-name`: Used for new features.
- `bugfix/bug-description`: Used to fix bugs during development.
- `hotfix/fix-name`: Urgent fixes applied directly to production.
- `release/x.y.z`: Preparation for a production release.

**Basic flow:**
```bash
1. Create a new branch from staging.
2. Develop your feature or fix.
3. Open a Pull Request (PR) to staging.
4. After testing and code review, merge into staging.
5. When ready for production, merge staging into master.
```
---

## ✍️ Conventional Commits

We follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification to maintain a clean and understandable commit history.

**Examples:**

- `feat: add login component`
- `fix: resolve user loading issue`
- `chore: update dependencies`
- `refactor: improve auth logic`
- `docs: update README documentation`
- `test: add unit tests for X component`

---

## 🗂️ Jira Task Flow

We use **Jira** for task management with the following status flow:

- **To Do** – Task is created but not started.
- **In Progress** – Task is currently being worked on.
- **Code Review** – Task is completed and under code review.
- **QA** – Task is being tested by QA team.
- **Ready for Release** – Task is validated and ready for production.
- **Done** – Task has been released to production.

**Additional context:**

- Tasks should be clear, concise, and well-scoped.
- Each task must include a description, acceptance criteria, and relevant assets (e.g., screenshots, links).
- Link the Jira ticket in the PR (e.g., `[PROJ-123]` in title).
- Use labels and priorities appropriately to support project visibility and tracking.

---

## ☁️ Deployment

The recommended deployment platform is [Vercel](https://vercel.com), which integrates seamlessly with GitHub.

Documentation: [Next.js Deployment Guide](https://nextjs.org/docs/app/building-your-application/deploying)

---

## 👥 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## 📄 License

This project is private. All rights reserved to Reach Social.

---
\```


---
# Changed Files Full Content

- Status: FETCHED_FROM_PR_HEAD
- Ref used: 6c0be5af44a249e8c8860a0609f624507e90b5b5
- Max chars per file: 20000
- Max total chars: 120000

## src/pages/auth/signup.tsx

- Change type: MODIFIED
- Additions: 20
- Deletions: 4

```text
import { HStack, Text, VStack } from "@chakra-ui/react";
import { zodResolver } from "@hookform/resolvers/zod";
import Head from "next/head";
import { useRouter } from "next/navigation";
import { Trans, useTranslation } from "next-i18next";
import { serverSideTranslations } from "next-i18next/serverSideTranslations";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { withSSRGuest } from "@/auth/middlewares/with-ssr-guest";
import { AuthLayout } from "@/components/layouts/auth-layout";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { ArrowRightIcon } from "@/components/ui/icons/arrow-right";
import { MailIcon } from "@/components/ui/icons/mail";
import { UsersIcon } from "@/components/ui/icons/users";
import { Input } from "@/components/ui/input";
import { Link } from "@/components/ui/link";
import { toaster } from "@/components/ui/toaster";
import { httpClient } from "@/services/http/client";

const nameRegex = /^[A-Za-zÀ-ÿ\s]+$/;

const stepOneSchema = z.object({
  firstName: z
    .string()
    .trim()
    .nonempty("First name is required")
    .min(2, "First name must be at least 2 characters")
    .regex(nameRegex, "Type a valid first name"),

  lastName: z
    .string()
    .trim()
    .nonempty("Last name is required")
    .min(2, "Last name must be at least 2 characters")
    .regex(nameRegex, "Type a valid last name"),

  email: z
    .string()
    .trim()
    .nonempty("Email is required")
    .email("Type a valid email address"),
});

type FormData = z.infer<typeof stepOneSchema>;

export default function Signup() {
  const [isAuthLoading, setIsAuthLoading] = useState(false);
  const [agreeToTerms, setAgreeToTerms] = useState(false);

  const { t } = useTranslation(["signup", "common", "routes"]);
  const router = useRouter();

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(stepOneSchema),
  });

  async function handleSignup(data: FormData) {
    toaster.promise(
      async () => {
        try {
          setIsAuthLoading(true);
          await httpClient.profiles.create({
            email: data.email.trim(),
            fullName: `${data.firstName.trim()} ${data.lastName.trim()}`,
          });

          router.push("/auth");
        } catch (error) {
          console.log(error);
          throw error;
        } finally {
          setIsAuthLoading(false);
        }
      },
      {
        success: {
          title: t("response.success.title"),
          description: t("response.success.description"),
        },
        error: { title: t("response.error") },
        loading: { title: t("response.loading") },
      },
    );
  }

  return (
    <AuthLayout.Root>
      <Head>
        <title>{t("signup.meta.title", { ns: "routes" })}</title>
      </Head>
      <AuthLayout.Header
        title={t("header.title")}
        description={<Trans t={t} i18nKey="header.sub_title" />}
      />
      <AuthLayout.Body>
        <VStack
          align="stretch"
          as="form"
          gapY={6}
          onSubmit={handleSubmit(handleSignup)}
        >
          <HStack align="start">
            <Input
              error={errors.firstName?.message}
              invalid={!!errors.firstName}
              label={t("form.first_name.label")}
              placeholder={t("form.first_name.placeholder")}
              startElement={<UsersIcon color="fg.subtle" />}
              {...register("firstName")}
            />

            <Input
              error={errors.lastName?.message}
              invalid={!!errors.lastName}
              label={t("form.last_name.label")}
              placeholder={t("form.last_name.placeholder")}
              {...register("lastName")}
            />
          </HStack>

          <Input
            error={errors.email?.message}
            invalid={!!errors.email}
            label={t("form.email.label")}
            placeholder={t("form.email.placeholder")}
            startElement={<MailIcon color="fg.subtle" />}
            {...register("email")}
          />

          <Checkbox
            size="sm"
            checked={agreeToTerms}
            mt="-2"
            onCheckedChange={(e) => setAgreeToTerms(!!e.checked)}
          >
            {
              <Trans
                t={t}
                i18nKey="form.terms_agree"
                components={{
                  terms: (
                    <Link
                      href="/terms"
                      target="_blank"
                      color="primary.solid"
                      fontWeight="medium"
                    />
                  ),
                  privacy: (
                    <Link
                      href="/privacy"
                      target="_blank"
                      color="primary.solid"
                      fontWeight="medium"
                    />
                  ),
                }}
              />
            }
          </Checkbox>

          <Button
            disabled={!agreeToTerms}
            type="submit"
            size="lg"
            loading={isSubmitting || isAuthLoading}
          >
            {t("submit")}
            <ArrowRightIcon />
          </Button>

          <AuthLayout.Separator>
            {t("or", { ns: "common" })}
          </AuthLayout.Separator>

          <Text fontSize="sm" color="fg.muted" mt="-2" textAlign="center">
            <Trans
              t={t}
              i18nKey="sign_in_cta"
              components={[
                <Link
                  key="0"
                  color="primary.solid"
                  fontWeight="medium"
                  href="/auth"
                />,
              ]}
            />
          </Text>
        </VStack>
      </AuthLayout.Body>
    </AuthLayout.Root>
  );
}

export const getServerSideProps = withSSRGuest(async ({ locale }) => {
  return {
    props: {
      ...(await serverSideTranslations(locale ?? "en", [
        "signup",
        "common",
        "routes",
      ])),
    },
  };
});
```


---
# Sanitized Pull Request Diff

```diff
From 734fc796c325aafd99e0a35006eb12fc6f1648db Mon Sep 17 00:00:00 2001
From: =?UTF-8?q?Jo=C3=A3o=20Victor=20Balvedi?= <joaovictorbalvedi@gmail.com>
Date: Thu, 23 Apr 2026 13:42:06 -0300
Subject: [PATCH 1/2] fix: RER-486 correcting signup displaying success on
 status 400

---
 src/pages/auth/signup.tsx | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/pages/auth/signup.tsx b/src/pages/auth/signup.tsx
index cb08a83e..f7290a6a 100644
--- a/src/pages/auth/signup.tsx
+++ b/src/pages/auth/signup.tsx
@@ -58,6 +58,7 @@ export default function Signup() {
           router.push("/auth");
         } catch (error) {
           console.log(error);
+          throw error;
         } finally {
           setIsAuthLoading(false);
         }

From 6c0be5af44a249e8c8860a0609f624507e90b5b5 Mon Sep 17 00:00:00 2001
From: =?UTF-8?q?Jo=C3=A3o=20Victor=20Balvedi?= <joaovictorbalvedi@gmail.com>
Date: Tue, 28 Apr 2026 14:27:13 -0300
Subject: [PATCH 2/2] fix: RER-486 applying validation to signup form

---
 src/pages/auth/signup.tsx | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)
diff --git a/src/pages/auth/signup.tsx b/src/pages/auth/signup.tsx
index f7290a6a..1ca5c0f7 100644
--- a/src/pages/auth/signup.tsx
+++ b/src/pages/auth/signup.tsx
@@ -19,11 +19,26 @@ import { Link } from "@/components/ui/link";
 import { toaster } from "@/components/ui/toaster";
 import { httpClient } from "@/services/http/client";
 
+const nameRegex = /^[A-Za-zÀ-ÿ\s]+$/;
+
 const stepOneSchema = z.object({
-  firstName: z.string().nonempty("First name is required"),
-  lastName: z.string().nonempty("Last name is required"),
+  firstName: z
+    .string()
+    .trim()
+    .nonempty("First name is required")
+    .min(2, "First name must be at least 2 characters")
+    .regex(nameRegex, "Type a valid first name"),
+
+  lastName: z
+    .string()
+    .trim()
+    .nonempty("Last name is required")
+    .min(2, "Last name must be at least 2 characters")
+    .regex(nameRegex, "Type a valid last name"),
+
   email: z
     .string()
+    .trim()
     .nonempty("Email is required")
     .email("Type a valid email address"),
 });
@@ -51,8 +66,8 @@ export default function Signup() {
         try {
           setIsAuthLoading(true);
           await httpClient.profiles.create({
-            email: data.email,
-            fullName: `${data.firstName} ${data.lastName}`,
+            email: data.email.trim(),
+            fullName: `${data.firstName.trim()} ${data.lastName.trim()}`,
           });
 
           router.push("/auth");

```
